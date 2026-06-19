pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property real brightness: 1.0
    
    property bool _initialized: false
    
    Process {
        id: brightProcess
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                var raw = data.trim();
                var parts = raw.split(",");
                if (parts.length >= 5) {
                    var cur = parseInt(parts[2]);
                    var max = parseInt(parts[4]);
                    if (max > 0) {
                        var val = cur / max;
                        var changed = Math.abs(root.brightness - val) > 0.005;
                        root.brightness = val;
                        if (root._initialized && changed) {
                            OsdService.showOsd(1, 1, "", "", "");
                        }
                    }
                }
                root._initialized = true;
            }
        }
    }
    
    Timer {
        running: true
        repeat: true
        interval: 50
        onTriggered: brightProcess.running = true
        Component.onCompleted: brightProcess.running = true
    }
}
