pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    
    property int percentage: 100
    property bool isCharging: false
    
    property bool _hasInitPercent: false
    property bool _hasInitCharge: false
    property int _lastNotifiedBattery: 100
    
    property Process capProcess: Process {
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        stdout: SplitParser {
            onRead: data => {
                var val = parseInt(data.trim());
                if (!isNaN(val)) {
                    if (root._hasInitPercent && val <= 20 && root._lastNotifiedBattery > 20) {
                        var p1 = Qt.createQmlObject('import Quickshell.Io; Process { command: ["notify-send", "-a", "Power", "--icon=battery-caution", "Low Battery", "Battery is at 20%"] }', root);
                        p1.running = true;
                    } else if (root._hasInitPercent && val <= 10 && root._lastNotifiedBattery > 10) {
                        var p2 = Qt.createQmlObject('import Quickshell.Io; Process { command: ["notify-send", "-u", "critical", "-a", "Power", "--icon=battery-empty", "Critical Battery", "Battery is at 10%"] }', root);
                        p2.running = true;
                    }
                    root._lastNotifiedBattery = val;
                    root.percentage = val;
                    root._hasInitPercent = true;
                }
            }
        }
    }
    
    property Process statProcess: Process {
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        stdout: SplitParser {
            onRead: data => {
                var newCharging = (data.trim() !== "Discharging" && data.trim() !== "Unknown");
                if (root.isCharging !== newCharging) {
                    if (root._hasInitCharge) {
                        var icon = newCharging ? "battery-charging" : "battery";
                        var text = newCharging ? "Plugged In" : "Unplugged";
                        var p3 = Qt.createQmlObject('import Quickshell.Io; Process { command: ["notify-send", "-a", "Power", "--icon=' + icon + '", "Battery", "' + text + '"] }', root);
                        p3.running = true;
                    }
                    root.isCharging = newCharging;
                }
                root._hasInitCharge = true;
            }
        }
    }
    
    property Timer poller: Timer {
        running: true
        repeat: true
        interval: 10000 // every 10 seconds
        onTriggered: {
            root.capProcess.running = true;
            root.statProcess.running = true;
        }
    }
    
    Component.onCompleted: {
        root.capProcess.running = true;
        root.statProcess.running = true;
    }
}
