pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property real brightness: 1.0
    
    property bool _initialized: false
    
    // Throttling for slider drags
    property real _pendingBrightness: -1
    property bool _isSetting: false

    function setBrightness(percent) {
        // Clamp to 0-100
        var p = Math.max(0, Math.min(100, percent));
        _pendingBrightness = p;
        
        if (!_isSetting) {
            _applyBrightness();
        }
    }
    
    function _applyBrightness() {
        if (_pendingBrightness < 0) return;
        
        _isSetting = true;
        var p = _pendingBrightness;
        _pendingBrightness = -1;
        
        // Optimistically update UI
        root.brightness = p / 100.0;
        
        var cmd = "brightnessctl set " + Math.round(p) + "%";
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
            _isSetting = false;
            // If another change came in while we were setting, apply it now
            if (_pendingBrightness >= 0) {
                _applyBrightness();
            }
        });
        proc.running = true;
    }
    
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
