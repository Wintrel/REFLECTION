pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property real volume: 0.0
    property bool isMuted: false
    
    // Internal flag to track initialization to prevent firing on load
    property bool _initialized: false
    
    function fetchVolume() {
        volFetcher.running = true;
    }
    
    // Throttling for slider drags
    property real _pendingVolume: -1
    property bool _isSetting: false

    function setVolume(percent) {
        // Clamp to 0-100 (or up to 150 for volume, but we'll stick to 100 for safety)
        var p = Math.max(0, Math.min(100, percent));
        _pendingVolume = p;
        
        if (!_isSetting) {
            _applyVolume();
        }
    }
    
    function _applyVolume() {
        if (_pendingVolume < 0) return;
        
        _isSetting = true;
        var p = _pendingVolume;
        _pendingVolume = -1;
        
        // Optimistically update UI
        root.volume = p / 100.0;
        
        var volStr = (p / 100.0).toFixed(2);
        var cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + volStr;
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
            _isSetting = false;
            // If another change came in while we were setting, apply it now
            if (_pendingVolume >= 0) {
                _applyVolume();
            }
        });
        proc.running = true;
    }

    property alias audioSinks: sinksModel
    ListModel { id: sinksModel }

    property bool _inSinks: false

    function scanSinks() {
        sinksModel.clear();
        _inSinks = false;
        wpctlStatusProcess.running = true;
    }
    
    function setDefaultSink(id) {
        // Optimistic update to prevent the UI from "blinking"
        for (var i = 0; i < sinksModel.count; i++) {
            sinksModel.setProperty(i, "isDefault", sinksModel.get(i).sinkId === id);
        }

        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["wpctl", "set-default", "' + id + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
        });
        proc.running = true;
    }

    Process {
        id: wpctlStatusProcess
        command: ["wpctl", "status"]
        stdout: SplitParser {
            onRead: data => {
                var line = data;
                if (line.includes("Sinks:")) { root._inSinks = true; return; }
                if (line.includes("Sources:")) { root._inSinks = false; return; }
                if (root._inSinks) {
                    var match = line.match(/^[^0-9\*]*(\*)?[^0-9]*(\d+)\.\s+(.*?)(?:\s+\[vol:.*\])?$/);
                    if (match) {
                        var isDefault = match[1] === '*';
                        var id = match[2];
                        var name = match[3].trim();
                        sinksModel.append({
                            "sinkId": id,
                            "name": name,
                            "isDefault": isDefault
                        });
                    }
                }
            }
        }
    }
    
    Process {
        id: volFetcher
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                var raw = data.trim();
                var parts = raw.split(" ");
                if (parts.length >= 2) {
                    var vol = parseFloat(parts[1]);
                    if (!isNaN(vol)) {
                        var newMuted = raw.indexOf("[MUTED]") !== -1;
                        
                        var changed = (Math.abs(root.volume - vol) > 0.001 || root.isMuted !== newMuted);
                        
                        root.volume = vol;
                        root.isMuted = newMuted;
                        if (root._initialized && changed) {
                            OsdService.showOsd(0, 1, "", "", "");
                        }
                    }
                }
                root._initialized = true;
            }
        }
    }
    
    Process {
        id: watcher
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                // Ensure we only match 'sink' and not 'sink-input'
                if (data.indexOf("'change' on sink ") !== -1 || data.indexOf("'change' on sink\n") !== -1 || data.indexOf("'change' on sink#") !== -1) {
                    root.fetchVolume();
                }
            }
        }
    }
    
    Component.onCompleted: {
        root.fetchVolume();
    }
}
