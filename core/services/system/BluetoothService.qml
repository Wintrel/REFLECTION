pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool isConnected: false
    property bool _initialized: false
    
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
                            var icon = newConnected ? "bluetooth_connected" : "bluetooth_disabled";
                            var text = newConnected ? "Bluetooth Connected" : "Bluetooth Disconnected";
                            var priority = newConnected ? 1 : 2; // Disconnect is Tier 2
                            OsdService.showOsd(2, priority, icon, text, "");
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
