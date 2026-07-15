pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../system"
import "../../state" as State

Singleton {
    id: root
    
    property bool isPlaying: false
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackArtUrl: ""
    property real position: 0
    property real length: 0
    property bool canSeek: true
    property string identity: "Cider"
    property var queue: []
    property var searchResults: []
    
    // Lyrics Properties
    property string currentLyrics: ""
    property bool hasSyncedLyrics: false
    property var parsedLyrics: []
    property int shuffleMode: 0
    property int repeatMode: 0
    property bool inFavorites: false
    property real volume: 1.0
    
    property bool ciderActive: trackTitle !== "" || isPlaying
    
    property var activePlayer: ciderActive ? root : mprisFallbackPlayer

    property var mprisFallbackPlayer: null
    property bool _isDaemonUpdate: false

    // Track MPRIS fallback natively here
    Instantiator {
        id: mprisInst
        model: Mpris.players
        
        delegate: Item {
            property var player: modelData
            Connections {
                target: player
                function onIsPlayingChanged() { updateFallback(); }
            }
        }
        onObjectAdded: updateFallback()
        onObjectRemoved: updateFallback()
    }
    
    function updateFallback() {
        if (mprisInst.count === 0) {
            root.mprisFallbackPlayer = null;
            return;
        }
        var best = null;
        var bestScore = -1;
        for (var i = 0; i < mprisInst.count; i++) {
            var p = mprisInst.objectAt(i).player;
            if (!p) continue;
            // Ignore cider if it exposes an MPRIS interface itself
            if (p.identity && p.identity.toLowerCase().indexOf("cider") !== -1) continue;
            
            var score = 0;
            if (p.isPlaying) score = 10;
            if (p.length > 0) score += 2;
            if (score > bestScore) {
                bestScore = score;
                best = p;
            }
        }
        root.mprisFallbackPlayer = best;
    }

    Connections {
        target: State.GlobalStates
        function onAmbientIdleActiveChanged() {
            if (State.GlobalStates.ambientIdleActive && root.activePlayer && root.activePlayer.isPlaying) {
                root.activePlayer.pause();
            }
        }
    }

    Process {
        id: ciderDaemon
        command: ["node", Quickshell.env("HOME") + "/.config/quickshell/reflection/scripts/cider_daemon.js"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                var line = data;
                if (line.trim() === "") return;
                try {
                    var parsed = JSON.parse(line);
                    if (parsed.__type === "search") {
                        root.searchResults = [];
                        root.searchResults = parsed.results || [];
                    } else if (parsed.__type === "lyrics") {
                        root.currentLyrics = parsed.text || "";
                        root.hasSyncedLyrics = !!parsed.synced;
                        let arr = [];
                        if (parsed.synced && parsed.text) {
                            var lines = parsed.text.split('\n');
                            for (var i = 0; i < lines.length; i++) {
                                // Match [mm:ss.xx]
                                var match = lines[i].match(/\[(\d+):(\d+\.\d+)\](.*)/);
                                if (match) {
                                    var mins = parseInt(match[1]);
                                    var secs = parseFloat(match[2]);
                                    var time = (mins * 60) + secs;
                                    arr.push({ time: time, text: match[3].trim() });
                                }
                            }
                        }
                        root.parsedLyrics = arr;
                    } else if (parsed.trackTitle !== undefined) {
                        root._isDaemonUpdate = true;
                        root.isPlaying = parsed.isPlaying;
                        root.trackTitle = parsed.trackTitle;
                        root.trackArtist = parsed.trackArtist;
                        root.trackArtUrl = parsed.trackArtUrl;
                        root.position = parsed.position;
                        root.length = parsed.length;
                        root.canSeek = parsed.canSeek;
                        if (parsed.queue !== undefined) root.queue = parsed.queue;
                        if (parsed.shuffleMode !== undefined) root.shuffleMode = parsed.shuffleMode;
                        if (parsed.repeatMode !== undefined) root.repeatMode = parsed.repeatMode;
                        if (parsed.inFavorites !== undefined) root.inFavorites = parsed.inFavorites;
                        if (parsed.volume !== undefined) root.volume = parsed.volume;
                        root._isDaemonUpdate = false;
                    }
                } catch (e) {}
            }
        }
    }
    
    onPositionChanged: {
        if (!_isDaemonUpdate) {
            ciderDaemon.write("seek " + Math.floor(position) + "\n");
        }
    }

    function togglePlaying() {
        ciderDaemon.write("playpause\n");
    }
    
    function pause() {
        ciderDaemon.write("pause\n");
    }
    
    function next() {
        ciderDaemon.write("next\n");
    }
    
    function previous() {
        ciderDaemon.write("previous\n");
    }

    function toggleShuffle() {
        ciderDaemon.write("toggleShuffle\n");
    }
    
    function toggleRepeat() {
        ciderDaemon.write("toggleRepeat\n");
    }
    
    function skipToId(id) {
        if (id) ciderDaemon.write("skipToId " + id + "\n");
    }
    
    function playTrack(id) {
        if (id) ciderDaemon.write("playTrack " + id + "\n");
    }
    
    function search(query) {
        if (query) ciderDaemon.write("search " + query + "\n");
    }
    
    function setVolume(v) {
        ciderDaemon.write("setVolume " + v + "\n");
    }
}
