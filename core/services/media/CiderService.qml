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
    property var userPlaylists: []
    property var forYouPlaylists: []
    property var currentPlaylistTracks: []
    property var currentPlaylist: null
    
    // Lyrics Properties
    property string currentLyrics: ""
    property bool hasSyncedLyrics: false
    property var parsedLyrics: []
    property int shuffleMode: 0
    property int repeatMode: 0
    property bool inFavorites: false
    property real volume: 1.0
    
    // Audio Lab Properties (Read-Only)
    property bool atmosEnabled: false
    property bool crossfadeEnabled: false
    property bool normalizationEnabled: false
    
    property bool ciderActive: trackTitle !== "" || isPlaying
    onCiderActiveChanged: updateActivePlayer()
    onIsPlayingChanged: updateActivePlayer()
    
    property var activePlayer: null

    property bool _isDaemonUpdate: false

    property real _lastUpdateRealTime: 0
    property real _lastUpdatePosition: 0

    Timer {
        id: positionInterpolator
        interval: 32 // ~30fps
        running: root.isPlaying
        repeat: true
        onTriggered: {
            if (!root._isDaemonUpdate) {
                var elapsed = Date.now() - root._lastUpdateRealTime;
                root._isDaemonUpdate = true; // prevent sending seek command
                root.position = root._lastUpdatePosition + (elapsed * 1000);
                root._isDaemonUpdate = false;
            }
        }
    }

    // Track MPRIS fallback natively here
    Instantiator {
        id: mprisInst
        model: Mpris.players
        
        delegate: Item {
            property var player: modelData
            Connections {
                target: player
                function onIsPlayingChanged() { updateActivePlayer(); }
            }
        }
        onObjectAdded: updateActivePlayer()
        onObjectRemoved: updateActivePlayer()
    }
    
    property bool _manualPlayerOverridden: false
    property string _manualPlayerId: ""

    function cycleFallbackPlayer() {
        var available = [];
        if (root.ciderActive) available.push(root);

        for (var i = 0; i < mprisInst.count; i++) {
            var p = mprisInst.objectAt(i).player;
            if (!p) continue;
            if (p.identity && p.identity.toLowerCase().indexOf("cider") !== -1) continue;
            available.push(p);
        }
        if (available.length === 0) return;
        
        var currentIndex = -1;
        if (root.activePlayer) {
            currentIndex = available.indexOf(root.activePlayer);
        }
        
        var nextIndex = (currentIndex + 1) % available.length;
        root.activePlayer = available[nextIndex];
        
        root._manualPlayerOverridden = true;
        if (available[nextIndex] === root) {
            root._manualPlayerId = "cider";
        } else {
            root._manualPlayerId = available[nextIndex].busName;
        }
    }

    function updateActivePlayer() {
        var available = [];
        if (root.ciderActive) available.push(root);

        for (var i = 0; i < mprisInst.count; i++) {
            var p = mprisInst.objectAt(i).player;
            if (!p) continue;
            if (p.identity && p.identity.toLowerCase().indexOf("cider") !== -1) continue;
            available.push(p);
        }
        
        if (available.length === 0) {
            root.activePlayer = null;
            root._manualPlayerOverridden = false;
            root._manualPlayerId = "";
            return;
        }

        if (root._manualPlayerOverridden) {
            if (root._manualPlayerId === "cider" && root.ciderActive) {
                root.activePlayer = root;
                return;
            }
            for (var j = 0; j < available.length; j++) {
                if (available[j] !== root && available[j].busName === root._manualPlayerId) {
                    root.activePlayer = available[j];
                    return;
                }
            }
            root._manualPlayerOverridden = false;
            root._manualPlayerId = "";
        }

        var best = null;
        var bestScore = -1;
        for (var k = 0; k < available.length; k++) {
            var score = 0;
            if (available[k] === root) score += 5; // Bias towards native cider
            if (available[k].isPlaying) score += 10;
            if (available[k].length > 0) score += 2;
            
            if (score > bestScore) {
                bestScore = score;
                best = available[k];
            }
        }
        root.activePlayer = best;
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
                    } else if (parsed.__type === "playlists") {
                        root.userPlaylists = [];
                        root.userPlaylists = parsed.results || [];
                    } else if (parsed.__type === "forYou") {
                        root.forYouPlaylists = [];
                        root.forYouPlaylists = parsed.results || [];
                    } else if (parsed.__type === "playlistTracks") {
                        root.currentPlaylistTracks = [];
                        root.currentPlaylistTracks = parsed.results || [];
                    } else if (parsed.__type === "config") {
                        if (parsed.audio) {
                            if (parsed.audio.atmos !== undefined) root.atmosEnabled = !!parsed.audio.atmos.enabled;
                            if (parsed.audio.crossfade !== undefined) root.crossfadeEnabled = !!parsed.audio.crossfade.enabled;
                            if (parsed.audio.normalization !== undefined) root.normalizationEnabled = !!parsed.audio.normalization;
                        }
                    } else if (parsed.__type === "lyrics") {
                        root.currentLyrics = parsed.text || "";
                        root.hasSyncedLyrics = !!parsed.synced;
                        let arr = [];
                        if (parsed.isCiderV2 && parsed.synced) {
                            arr = parsed.lines;
                        } else if (parsed.synced && parsed.text) {
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
                        if (parsed.isPlaying !== undefined) root.isPlaying = parsed.isPlaying;
                        if (parsed.trackTitle !== undefined) root.trackTitle = parsed.trackTitle;
                        if (parsed.trackArtist !== undefined) root.trackArtist = parsed.trackArtist;
                        if (parsed.trackArtUrl !== undefined) root.trackArtUrl = parsed.trackArtUrl;
                        if (parsed.position !== undefined) {
                            root.position = parsed.position;
                            root._lastUpdatePosition = parsed.position;
                            root._lastUpdateRealTime = Date.now();
                        }
                        if (parsed.length !== undefined) root.length = parsed.length;
                        if (parsed.canSeek !== undefined) root.canSeek = parsed.canSeek;
                        if (parsed.queue !== undefined) root.queue = parsed.queue;
                        if (parsed.shuffleMode !== undefined) root.shuffleMode = parsed.shuffleMode;
                        if (parsed.repeatMode !== undefined) root.repeatMode = parsed.repeatMode;
                        if (parsed.inFavorites !== undefined) root.inFavorites = parsed.inFavorites;
                        if (parsed.volume !== undefined) root.volume = parsed.volume;
                        root._isDaemonUpdate = false;
                    }
                } catch (e) {
                    console.error("JSON Parse Error in CiderService:", e, "Line:", line);
                }
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
    
    function fetchConfig() {
        ciderDaemon.write("fetchConfig\n");
    }
    
    function toggleAtmos(state) {
        ciderDaemon.write("toggleAudioFeature atmos " + state + "\n");
    }
    
    function toggleCrossfade(state) {
        ciderDaemon.write("toggleAudioFeature crossfade " + state + "\n");
    }
    
    function toggleNormalization(state) {
        ciderDaemon.write("toggleAudioFeature normalization " + state + "\n");
    }
    
    function fetchPlaylists() {
        ciderDaemon.write("playlists\n");
    }
    
    function fetchForYouPlaylists() {
        ciderDaemon.write("foryou\n");
    }
    
    function fetchPlaylistTracks(href) {
        if (href) ciderDaemon.write("playlistTracks " + href + "\n");
    }
    
    function playPlaylist(type, id) {
        if (id) ciderDaemon.write("playPlaylist " + type + " " + id + "\n");
    }
}
