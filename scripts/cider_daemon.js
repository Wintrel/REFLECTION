const io = require("socket.io-client");

const TOKEN = "ut8sjz8mmzcp232zqy51m25n";
const socket = io("http://127.0.0.1:10767", {
    extraHeaders: {
        "apptoken": TOKEN,
        "apitoken": TOKEN
    }
});

let state = {
    isPlaying: false,
    trackTitle: "",
    trackArtist: "",
    trackArtUrl: "",
    position: 0,
    length: 0,
    canSeek: true,
    identity: "Cider",
    queue: [],
    shuffleMode: 0,
    repeatMode: 0,
    inFavorites: false,
    volume: 1.0
};

function printState() {
    console.log(JSON.stringify(state));
}

function updateVolume() {
    fetch("http://127.0.0.1:10767/api/v1/playback/volume", {
        headers: { "apptoken": TOKEN }
    }).then(res => res.json()).then(data => {
        if (data && data.volume !== undefined) {
            state.volume = data.volume;
            printState();
        }
    }).catch(() => {});
}

function updateNowPlaying() {
    fetch("http://127.0.0.1:10767/api/v1/playback/now-playing", {
        headers: { "apptoken": TOKEN }
    }).then(res => res.json()).then(data => {
        if (data && data.info) {
            state.trackTitle = data.info.name || "";
            state.trackArtist = data.info.artistName || "";
            state.trackArtUrl = data.info.artwork ? data.info.artwork.url.replace("{w}", "600").replace("{h}", "600") : "";
            state.length = Math.floor((data.info.durationInMillis || 0) * 1000); 
            state.shuffleMode = data.info.shuffleMode || 0;
            state.repeatMode = data.info.repeatMode || 0;
            state.inFavorites = !!data.info.inFavorites;
            printState();
        }
    }).catch(() => {});
}

socket.on("connect", () => {
    updateNowPlaying();
    updateQueue();
    updateVolume();
});

function updateQueue() {
    fetch("http://127.0.0.1:10767/api/v1/playback/queue", {
        headers: { "apptoken": TOKEN }
    }).then(res => res.json()).then(data => {
        if (Array.isArray(data)) {
            state.queue = data.map(item => {
                var attr = item.attributes || {};
                var artwork = attr.artwork ? attr.artwork.url.replace("{w}", "100").replace("{h}", "100") : "";
                
                var totalSeconds = Math.floor((attr.durationInMillis || 0) / 1000);
                var durationStr = Math.floor(totalSeconds / 60) + ":" + ((totalSeconds % 60) < 10 ? "0" : "") + (totalSeconds % 60);
                
                return {
                    id: item.id || "",
                    title: attr.name || "",
                    artist: attr.artistName || "",
                    album: attr.albumName || "",
                    artwork: artwork,
                    duration: durationStr,
                    isExplicit: attr.contentRating === "explicit",
                    inFavorites: !!attr.inFavorites,
                    traits: attr.audioTraits || []
                };
            });
            printState();
        }
    }).catch(() => {});
}

const onevent = socket.onevent;
socket.onevent = function (packet) {
    const args = packet.data || [];
    if (args[0] === "API:Playback") {
        const payload = args[1];
        if (payload.type === "playbackStatus.playbackTimeDidChange") {
            const data = payload.data;
            state.isPlaying = data.isPlaying;
            state.position = Math.floor(data.currentPlaybackTime * 1000000); // QML expects microseconds
            state.length = Math.floor(data.currentPlaybackDuration * 1000000);
            printState();
        } else if (payload.type === "playbackStatus.playbackStateDidChange") {
            state.isPlaying = payload.data.state === "playing" || payload.data.state === "playing_true";
            printState();
        } else if (payload.type === "playbackStatus.nowPlayingItemDidChange") {
            updateNowPlaying();
            updateQueue();
        }
    }
    onevent.call(this, packet);
};

// handle basic REST inputs from stdin
const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on('line', function(line){
    if (line.trim() === "playpause" || line.trim() === "togglePlaying") {
        fetch("http://127.0.0.1:10767/api/v1/playback/playpause", { method: "POST", headers: { "apptoken": TOKEN }});
    } else if (line.trim() === "next") {
        fetch("http://127.0.0.1:10767/api/v1/playback/next", { method: "POST", headers: { "apptoken": TOKEN }});
    } else if (line.trim() === "previous") {
        fetch("http://127.0.0.1:10767/api/v1/playback/previous", { method: "POST", headers: { "apptoken": TOKEN }});
    } else if (line.trim() === "pause") {
        fetch("http://127.0.0.1:10767/api/v1/playback/pause", { method: "POST", headers: { "apptoken": TOKEN }});
    } else if (line.trim() === "toggleShuffle") {
        fetch("http://127.0.0.1:10767/api/v1/playback/toggle-shuffle", { method: "POST", headers: { "apptoken": TOKEN }}).then(() => updateNowPlaying());
    } else if (line.trim() === "toggleRepeat") {
        fetch("http://127.0.0.1:10767/api/v1/playback/toggle-repeat", { method: "POST", headers: { "apptoken": TOKEN }}).then(() => updateNowPlaying());
    } else if (line.startsWith("setVolume ")) {
        const val = parseFloat(line.split(" ")[1]);
        fetch("http://127.0.0.1:10767/api/v1/playback/volume", { 
            method: "POST", 
            headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
            body: JSON.stringify({ "volume": val })
        }).then(() => { state.volume = val; printState(); });
    } else if (line.startsWith("seek ")) {
        const val = parseInt(line.split(" ")[1], 10);
        fetch("http://127.0.0.1:10767/api/v1/playback/seek", { 
            method: "POST", 
            headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
            body: JSON.stringify({ "position": val / 1000000.0 })
        });
    } else if (line.trim() === "queue") {
        updateQueue();
    }
});
