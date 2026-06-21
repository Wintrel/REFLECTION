pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool isConnected: false
    property bool isBluetoothEnabled: false
    property bool _initialized: false

    Connections {
        target: PromptService
        function onSubmitted(text) {
            if (PromptService.promptType === "bluetooth_passkey" || PromptService.promptType === "bluetooth_pin") {
                submitPairingResponse(PromptService.promptTarget, text);
            }
        }
    }

    function toggleBluetooth() {
        // Optimistic update for instant UI feedback
        isBluetoothEnabled = !isBluetoothEnabled;
        var cmd = isBluetoothEnabled ? "bluetoothctl power on" : "bluetoothctl power off";
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
        });
        proc.running = true;
    }

    // Poll actual radio power state
    Process {
        id: btPowerPoller
        command: ["sh", "-c", "bluetoothctl show | grep 'Powered: yes' | wc -l"]
        stdout: SplitParser {
            onRead: data => {
                var count = parseInt(data.trim());
                if (!isNaN(count)) {
                    root.isBluetoothEnabled = (count > 0);
                }
            }
        }
    }
    Timer {
        running: true
        repeat: true
        interval: 3000
        onTriggered: btPowerPoller.running = true
        Component.onCompleted: btPowerPoller.running = true
    }

    property alias bluetoothDevices: devicesModel
    ListModel { id: devicesModel }

    property var _currentDevice: null

    function scanBluetooth() {
        devicesModel.clear();
        btScanProcess.running = true;
    }

    // Persistent background D-Bus Agent
    Process {
        id: btAgentProcess
        command: ["python3", "/home/wintrel/Documents/REFLECTION/core/scripts/bt_agent.py"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line.startsWith("PROMPT|")) {
                    var parts = line.split("|");
                    var type = parts[1];
                    var mac = parts[2];
                    var payload = parts[3];
                    
                    if (type === "PASSKEY") {
                        PromptService.requestBluetoothPasskey(mac, payload);
                    } else if (type === "PIN") {
                        PromptService.requestBluetoothPin(mac);
                    } else if (type === "AUTHORIZE") {
                        // For generic authorization, just use the passkey UI with a dummy code
                        PromptService.requestBluetoothPasskey(mac, "Auth");
                    }
                }
            }
        }
    }

    property bool _lastPairingRejected: false

    function connectDevice(mac, trusted, name, icon) {
        var cmd = "bluetoothctl pair " + mac + " && bluetoothctl connect " + mac;
        
        ActionProgressService.actionStarted("Connecting to " + (name || "Device") + "...", icon === "audio-headset" ? "headphones" : (icon === "input-mouse" ? "mouse" : "bluetooth"), "bluetooth");
        
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        
        proc.exited.connect(function(code) {
            proc.destroy();
            scanBluetooth();
            
            // Assume 0 means success
            if (code === 0) {
                ActionProgressService.actionFinished("Connected", "check", true);
            } else {
                if (_lastPairingRejected) {
                    ActionProgressService.actionFinished("Rejected", "close", false);
                    _lastPairingRejected = false;
                } else {
                    ActionProgressService.actionFinished("Failed to Connect", "close", false);
                }
            }
        });
        proc.running = true;
    }
    
    function submitPairingResponse(mac, response) {
        // Echo to the python agent named pipe
        var pipePath = "/tmp/bt_agent_in";
        var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "echo \'' + response + '\' > ' + pipePath + '"] }', root);
        p.exited.connect(function() { p.destroy(); });
        p.running = true;
        
        if (response.toLowerCase() === "no") {
            _lastPairingRejected = true;
            ActionProgressService.actionStarted("Rejecting...", "bluetooth", "bluetooth");
            ActionProgressService.actionFinished("Rejected", "close", false);
        } else {
            _lastPairingRejected = false;
            ActionProgressService.actionStarted("Completing...", "bluetooth", "bluetooth");
            ActionProgressService.actionFinished("Paired", "check", true);
        }
    }

    function disconnectDevice(mac, name) {
        var cmd = "bluetoothctl disconnect " + mac;
        
        ActionProgressService.actionStarted("Disconnecting...", "bluetooth", "bluetooth");
        
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function(code) {
            proc.destroy();
            scanBluetooth();
            
            if (code === 0) {
                ActionProgressService.actionFinished("Disconnected", "check", true);
            } else {
                ActionProgressService.actionFinished("Failed", "close", false);
            }
        });
        proc.running = true;
    }

    function forgetDevice(mac, name) {
        var cmd = "bluetoothctl remove " + mac;
        
        ActionProgressService.actionStarted("Forgetting " + (name || "Device") + "...", "bluetooth", "bluetooth");
        
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function(code) {
            proc.destroy();
            scanBluetooth();
            
            if (code === 0) {
                ActionProgressService.actionFinished("Forgot Device", "delete", true);
            } else {
                ActionProgressService.actionFinished("Failed to Forget", "close", false);
            }
        });
        proc.running = true;
    }

    Process {
        id: btScanProcess
        command: ["bash", "-c", "for dev in $(bluetoothctl devices | awk '{print $2}'); do echo \"DEV|$dev\"; bluetoothctl info $dev | grep -E 'Name:|Icon:|Paired:|Trusted:|Connected:|ServicesResolved:'; done"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line === "") return;

                if (line.startsWith("DEV|")) {
                    if (root._currentDevice) {
                        devicesModel.append(root._currentDevice);
                    }
                    var mac = line.substring(4);
                    root._currentDevice = {
                        "mac": mac,
                        "name": mac,
                        "icon": "bluetooth",
                        "paired": false,
                        "trusted": false,
                        "connected": false,
                        "servicesResolved": false
                    };
                    return;
                }

                if (root._currentDevice) {
                    if (line.startsWith("Name:")) {
                        root._currentDevice.name = line.substring(5).trim();
                    } else if (line.startsWith("Icon:")) {
                        root._currentDevice.icon = line.substring(5).trim();
                    } else if (line.startsWith("Paired:")) {
                        root._currentDevice.paired = (line.substring(7).trim() === "yes");
                    } else if (line.startsWith("Trusted:")) {
                        root._currentDevice.trusted = (line.substring(8).trim() === "yes");
                    } else if (line.startsWith("Connected:")) {
                        root._currentDevice.connected = (line.substring(10).trim() === "yes");
                    } else if (line.startsWith("ServicesResolved:")) {
                        root._currentDevice.servicesResolved = (line.substring(17).trim() === "yes");
                    }
                }
            }
        }
        onExited: {
            if (root._currentDevice) {
                devicesModel.append(root._currentDevice);
            }
            root._currentDevice = null;
        }
    }
    
    // Active scanner to discover new unpaired devices
    property bool isScanning: btActiveScanner.running
    Process {
        id: btActiveScanner
        command: ["bluetoothctl", "--timeout", "10", "scan", "on"]
        onExited: scanBluetooth() // Refresh list once the active scan finishes
    }
    
    function startActiveScan() {
        if (!btActiveScanner.running) {
            btActiveScanner.running = true;
            // Also make the laptop discoverable for 3 minutes (default timeout)
            var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bluetoothctl", "discoverable", "on"] }', root);
            p.exited.connect(function() { p.destroy(); });
            p.running = true;
        }
    }
    
    // Check if ANY device is connected
    Process {
        id: btPoller
        // `bluetoothctl info` exits with 1 if no default controller or no device connected usually,
        // or we can parse `bluetoothctl devices Connected`
        command: ["bash", "-c", "bluetoothctl info | grep 'Connected: yes' | wc -l"]
        stdout: SplitParser {
            onRead: data => {
                var count = parseInt(data.trim());
                if (!isNaN(count)) {
                    var newConnected = (count > 0);
                    if (root.isConnected !== newConnected) {
                        if (root._initialized) {
                            // Only show the generic OSD if we aren't already showing the custom Action Progress UI
                            // AND if we haven't recently (last 10s) triggered a Bluetooth action.
                            var recentlyTriggered = (ActionProgressService.lastActionContext === "bluetooth" && (Date.now() - ActionProgressService.lastActionTime) < 10000);
                            
                            if (!ActionProgressService.inProgress && !ActionProgressService.isResolving && !recentlyTriggered) {
                                var icon = newConnected ? "bluetooth_connected" : "bluetooth_disabled";
                                var text = newConnected ? "Bluetooth Connected" : "Bluetooth Disconnected";
                                var priority = newConnected ? 1 : 2; // Disconnect is Tier 2
                                OsdService.showOsd(2, priority, icon, text, "");
                            }
                        }
                        root.isConnected = newConnected;
                    }
                    root._initialized = true;
                }
            }
        }
    }
    
    Timer {
        running: true
        repeat: true
        interval: 3000
        onTriggered: btPoller.running = true
        Component.onCompleted: btPoller.running = true
    }
}
