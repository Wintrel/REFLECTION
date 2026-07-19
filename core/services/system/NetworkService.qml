pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool isConnected: false // Default to false so the initial read registers as a sync
    property bool isWifiEnabled: false
    property bool _initialized: false

    function toggleWifi() {
        // Optimistic update for instant UI feedback
        isWifiEnabled = !isWifiEnabled;
        var cmd = isWifiEnabled ? "nmcli radio wifi on" : "nmcli radio wifi off";
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
        });
        proc.running = true;
    }

    // Poll actual radio state every 3 seconds to catch external changes
    Process {
        id: wifiRadioPoller
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: data => {
                var output = data.trim().toLowerCase();
                if (output === "enabled") root.isWifiEnabled = true;
                else if (output === "disabled") root.isWifiEnabled = false;
            }
        }
    }
    Timer {
        running: true
        repeat: true
        interval: 3000
        onTriggered: wifiRadioPoller.running = true
        Component.onCompleted: {
            wifiRadioPoller.running = true;
            scanWifi();
        }
    }

    property alias wifiNetworks: networksModel
    ListModel { id: networksModel }

    property var knownNetworks: []

    function scanWifi() {
        knownNetworksProcess.running = true;
    }

    property string connectingSsid: ""
    property string connectedSsid: ""

    Connections {
        target: PromptService
        function onSubmitted(text) {
            if (PromptService.promptType === "wifi") {
                connectToWifi(PromptService.promptTarget, text);
            }
        }
    }

    function connectToWifi(ssid, password) {
        connectingSsid = ssid;
        ActionProgressService.actionStarted("Connecting to " + ssid + "...", "wifi", "wifi");
        
        var qmlStr = "";
        if (password === "") {
            // Known or open network
            qmlStr = 'import Quickshell.Io; Process { command: ["nmcli", "connection", "up", "id", ' + JSON.stringify(ssid) + '] }';
        } else {
            // Secure network
            qmlStr = 'import Quickshell.Io; Process { command: ["nmcli", "device", "wifi", "connect", ' + JSON.stringify(ssid) + ', "password", ' + JSON.stringify(password) + '] }';
        }
        var proc = Qt.createQmlObject(qmlStr, root);
        proc.exited.connect(function(code) {
            proc.destroy();
            connectingSsid = "";
            scanWifi(); // refresh status
            
            if (code === 0) {
                ActionProgressService.actionFinished("Connected", "check", true);
            } else {
                ActionProgressService.actionFinished("Failed to Connect", "close", false);
            }
        });
        proc.running = true;
    }

    function disconnectWifi(ssid) {
        connectingSsid = ssid;
        ActionProgressService.actionStarted("Disconnecting...", "wifi_off", "wifi");
        
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["nmcli", "connection", "down", "id", ' + JSON.stringify(ssid) + '] }', root);
        proc.exited.connect(function(code) {
            proc.destroy();
            connectingSsid = "";
            scanWifi(); // refresh status
            
            if (code === 0) {
                ActionProgressService.actionFinished("Disconnected", "check", true);
            } else {
                ActionProgressService.actionFinished("Failed", "close", false);
            }
        });
        proc.running = true;
    }

    function forgetWifi(ssid) {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["nmcli", "connection", "delete", "id", ' + JSON.stringify(ssid) + '] }', root);
        proc.exited.connect(function() {
            proc.destroy();
            // Remove from knownNetworks array
            var idx = root.knownNetworks.indexOf(ssid);
            if (idx !== -1) {
                root.knownNetworks.splice(idx, 1);
            }
            scanWifi(); // refresh status
        });
        proc.running = true;
    }

    Process {
        id: knownNetworksProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line === "") return;
                var parts = line.split(":");
                if (parts.length >= 2 && parts[1] === "802-11-wireless") {
                    if (root.knownNetworks.indexOf(parts[0]) === -1) {
                        root.knownNetworks.push(parts[0]);
                    }
                }
            }
        }
        onExited: {
            // Instead of clearing the whole model (which causes a UI blink),
            // we just reset the active states and let the scan update them.
            for (var i = 0; i < networksModel.count; i++) {
                networksModel.setProperty(i, "inUse", false);
            }
            wifiScanProcess.running = true;
        }
    }

    Process {
        id: wifiScanProcess
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "dev", "wifi"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line === "") return;
                var parts = line.split(":");
                if (parts.length >= 4) {
                    var ssid = parts[0];
                    if (ssid === "") return; // ignore hidden networks usually
                    var signal = parseInt(parts[1]);
                    var security = parts[2];
                    var inUse = parts[3] === "*";
                    var isKnown = root.knownNetworks.indexOf(ssid) !== -1;
                    if (inUse) root.connectedSsid = ssid;
                    
                    // Prevent duplicates (nmcli sometimes returns multiple BSSIDs for same SSID)
                    var exists = false;
                    for (var i=0; i<networksModel.count; i++) {
                        if (networksModel.get(i).ssid === ssid) {
                            exists = true;
                            // Update signal if this BSSID is stronger
                            if (signal > networksModel.get(i).signal) {
                                networksModel.setProperty(i, "signal", signal);
                            }
                            if (inUse) networksModel.setProperty(i, "inUse", true);
                            networksModel.setProperty(i, "isKnown", isKnown);
                            break;
                        }
                    }
                    if (!exists) {
                        networksModel.append({
                            "ssid": ssid,
                            "signal": isNaN(signal) ? 0 : signal,
                            "security": security,
                            "inUse": inUse,
                            "isKnown": isKnown
                        });
                    }
                }
            }
        }
    }
    
    Process {
        id: netMonitor
        
        // 1. Fetch initial state immediately
        // 2. Fall into 'nmcli monitor' to listen for all future changes infinitely
        command: ["sh", "-c", "nmcli -t -f STATE general && nmcli monitor"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                var output = data.trim().toLowerCase();
                if (output === "") return;
                
                var newConnected = false;
                
                // A. Parse the initial single-word state (from nmcli -t -f STATE)
                if (output === "connected" || output === "connected (site only)" || output === "connected (local only)") {
                    newConnected = true;
                } 
                else if (output === "disconnected" || output === "connecting") {
                    newConnected = false;
                    if (output === "disconnected") root.connectedSsid = "";
                }
                // B. Parse the continuous monitor stream (from nmcli monitor)
                else if (output.includes("state")) {
                    newConnected = output.includes("'connected'") || 
                                   output.includes("'connected (site only)'") || 
                                   output.includes("'connected (local only)'");
                } 
                else {
                    // Ignore other random nmcli monitor logs (like interface IP updates)
                    return; 
                }
                
                // If the state has actually changed from our known state
                if (root.isConnected !== newConnected) {
                    if (root._initialized) {
                        var recentlyTriggered = (ActionProgressService.lastActionContext === "wifi" && (Date.now() - ActionProgressService.lastActionTime) < 10000);
                        
                        if (!ActionProgressService.inProgress && !ActionProgressService.isResolving && !recentlyTriggered) {
                            var icon = newConnected ? "wifi" : "wifi_off";
                            var text = newConnected ? "Wi-Fi Connected" : "Connection Lost";
                            var priority = newConnected ? 1 : 2; 
                            
                            OsdService.showOsd(2, priority, icon, text, "");
                        }
                    }
                    root.isConnected = newConnected;
                }
                // Initialization is complete after the very first valid read
                root._initialized = true;
            }
        }
        
        // Safety net: If the shell script dies for any reason, restart it automatically
        onRunningChanged: {
            if (!running) {
                running = true;
            }
        }
    }
}