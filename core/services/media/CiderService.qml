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
                    if (parsed.trackTitle !== undefined) {
                        root._isDaemonUpdate = true;
                        root.isPlaying = parsed.isPlaying;
                        root.trackTitle = parsed.trackTitle;
                        root.trackArtist = parsed.trackArtist;
                        root.trackArtUrl = parsed.trackArtUrl;
                        root.position = parsed.position;
                        root.length = parsed.length;
                        root.canSeek = parsed.canSeek;
                        if (parsed.queue !== undefined) root.queue = parsed.queue;
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
}
