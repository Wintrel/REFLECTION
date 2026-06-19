pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property real volume: 0.0
    property bool isMuted: false
    signal osdTriggered()
    
    // Internal flag to track initialization to prevent firing on load
    property bool _initialized: false
    
    function fetchVolume() {
        volFetcher.running = true;
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
                            root.osdTriggered();
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
