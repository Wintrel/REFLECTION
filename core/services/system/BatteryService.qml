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
                        OsdService.showOsd(2, 2, "battery_alert", "Battery 20% Remaining", "#E5C07B");
                    } else if (root._hasInitPercent && val <= 10 && root._lastNotifiedBattery > 10) {
                        OsdService.showOsd(2, 3, "battery_alert", "⚠ Battery Critical – 10% Remaining", "#E06C75");
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
                        var icon = newCharging ? "battery_charging_full" : "battery_horiz_050";
                        var text = newCharging ? "Charging" : "Unplugged";
                        OsdService.showOsd(2, 1, icon, text, "");
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
