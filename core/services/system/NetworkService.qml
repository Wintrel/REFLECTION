pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool isConnected: false // Default to false so the initial read registers as a sync
    property bool _initialized: false
    
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
                        var icon = newConnected ? "wifi" : "wifi_off";
                        var text = newConnected ? "Wi-Fi Connected" : "Connection Lost";
                        var priority = newConnected ? 1 : 2; 
                        
                        OsdService.showOsd(2, priority, icon, text, "");
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