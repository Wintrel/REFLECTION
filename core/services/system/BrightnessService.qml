pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property real brightness: 1.0
    signal osdTriggered()
    
    property bool _initialized: false
    
    Process {
        id: brightnessPoller
        command: ["bash", "-c", "while true; do max=$(brightnessctl max 2>/dev/null); cur=$(brightnessctl get 2>/dev/null); if [ ! -z \"$max\" ] && [ \"$max\" -ne 0 ]; then awk \"BEGIN {print $cur/$max}\"; fi; sleep 0.1; done"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var val = parseFloat(data.trim());
                if (!isNaN(val)) {
                    var changed = Math.abs(root.brightness - val) > 0.005;
                    root.brightness = val;
                    if (root._initialized && changed) {
                        root.osdTriggered();
                    }
                }
                root._initialized = true;
            }
        }
    }
}
