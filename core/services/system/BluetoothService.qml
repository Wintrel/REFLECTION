pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool isConnected: false
    property bool isBluetoothEnabled: false
    property bool _initialized: false

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

    function scanBluetooth() {
        devicesModel.clear();
        btScanProcess.running = true;
    }

    Process {
        id: btScanProcess
        // We grep 'Device ' so we only get lines like "Device AA:BB:CC:DD:EE:FF Headset"
        command: ["sh", "-c", "bluetoothctl devices | grep '^Device'"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line === "") return;
                // Parse "Device MAC Name"
                var match = line.match(/^Device ([0-9A-Fa-f:]+) (.+)$/);
                if (match) {
                    var mac = match[1];
                    var name = match[2];
                    devicesModel.append({
                        "mac": mac,
                        "name": name,
                        "connected": false // We can mock false or run another command to check connected state
                    });
                }
            }
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
