pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property real volume: 0.0
    property bool isMuted: false
    property real micVolume: 0.0
    property bool micIsMuted: false
    
    // Internal flag to track initialization to prevent firing on load
    property bool _initialized: false
    property bool _micInitialized: false
    
    function fetchVolume() {
        volFetcher.running = true;
    }
    
    function fetchMicVolume() {
        micVolFetcher.running = true;
    }
    
    // Throttling for slider drags
    property real _pendingVolume: -1
    property bool _isSetting: false
    
    property real _micPendingVolume: -1
    property bool _micIsSetting: false

    function setVolume(percent) {
        var p = Math.max(0, Math.min(100, percent));
        _pendingVolume = p;
        
        if (!_isSetting) {
            _applyVolume();
        }
    }
    
    function setMicVolume(percent) {
        var p = Math.max(0, Math.min(100, percent));
        _micPendingVolume = p;
        
        if (!_micIsSetting) {
            _applyMicVolume();
        }
    }
    
    function _applyVolume() {
        if (_pendingVolume < 0) return;
        
        _isSetting = true;
        var p = _pendingVolume;
        _pendingVolume = -1;
        
        var volStr = (p / 100.0).toFixed(2);
        
        // Optimistically update UI using the exact value sent to wpctl
        root.volume = parseFloat(volStr);
        
        var cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + volStr;
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
            _isSetting = false;
            if (_pendingVolume >= 0) {
                _applyVolume();
            }
        });
        proc.running = true;
    }
    
    function _applyMicVolume() {
        if (_micPendingVolume < 0) return;
        
        _micIsSetting = true;
        var p = _micPendingVolume;
        _micPendingVolume = -1;
        
        var volStr = (p / 100.0).toFixed(2);
        
        root.micVolume = parseFloat(volStr);
        
        var cmd = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ " + volStr;
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
            _micIsSetting = false;
            if (_micPendingVolume >= 0) {
                _applyMicVolume();
            }
        });
        proc.running = true;
    }

    property alias audioSinks: sinksModel
    ListModel { id: sinksModel }
    
    property alias audioSources: sourcesModel
    ListModel { id: sourcesModel }

    property bool _inSinks: false
    property bool _inSources: false

    function scanSinks() {
        sinksModel.clear();
        sourcesModel.clear();
        _inSinks = false;
        _inSources = false;
        wpctlStatusProcess.running = true;
    }
    
    function setDefaultSink(id) {
        for (var i = 0; i < sinksModel.count; i++) {
            sinksModel.setProperty(i, "isDefault", sinksModel.get(i).sinkId === id);
        }

        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["wpctl", "set-default", "' + id + '"] }', root);
        proc.exited.connect(function() {
            proc.destroy();
        });
        proc.running = true;
    }
    
    function setDefaultSource(id) {
        for (var i = 0; i < sourcesModel.count; i++) {
            sourcesModel.setProperty(i, "isDefault", sourcesModel.get(i).sinkId === id);
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
                if (line.includes("Sinks:")) { root._inSinks = true; root._inSources = false; return; }
                if (line.includes("Sources:")) { root._inSinks = false; root._inSources = true; return; }
                if (line.includes("Filters:") || line.includes("Streams:") || line.includes("Settings:") || line.includes("Clients:")) { 
                    root._inSinks = false; 
                    root._inSources = false; 
                    return; 
                }
                
                if (root._inSinks || root._inSources) {
                    var match = line.match(/^[^0-9\*]*(\*)?[^0-9]*(\d+)\.\s+(.*?)(?:\s+\[vol:.*\])?$/);
                    if (match) {
                        var isDefault = match[1] === '*';
                        var id = match[2];
                        var name = match[3].trim();
                        if (root._inSinks) {
                            sinksModel.append({
                                "sinkId": id,
                                "name": name,
                                "isDefault": isDefault
                            });
                        } else if (root._inSources) {
                            sourcesModel.append({
                                "sinkId": id, // Using same property for component reuse
                                "name": name,
                                "isDefault": isDefault
                            });
                        }
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
        id: micVolFetcher
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: SplitParser {
            onRead: data => {
                var raw = data.trim();
                var parts = raw.split(" ");
                if (parts.length >= 2) {
                    var vol = parseFloat(parts[1]);
                    if (!isNaN(vol)) {
                        var newMuted = raw.indexOf("[MUTED]") !== -1;
                        root.micVolume = vol;
                        root.micIsMuted = newMuted;
                    }
                }
                root._micInitialized = true;
            }
        }
    }
    
    Process {
        id: watcher
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.indexOf("'change' on sink ") !== -1 || data.indexOf("'change' on sink\n") !== -1 || data.indexOf("'change' on sink#") !== -1) {
                    root.fetchVolume();
                }
                if (data.indexOf("'change' on source ") !== -1 || data.indexOf("'change' on source\n") !== -1 || data.indexOf("'change' on source#") !== -1) {
                    root.fetchMicVolume();
                }
            }
        }
    }
    
    Component.onCompleted: {
        root.fetchVolume();
        root.fetchMicVolume();
    }
}
