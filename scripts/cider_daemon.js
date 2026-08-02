const io = require("socket.io-client");

const TOKEN = "fdbu2akop0ad66c7n9obcoet"; 
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
    trackId: "",
    length: 0,
    position: 0,
    volume: 0,
    shuffleMode: 0,
    repeatMode: 0,
    inFavorites: false,
    queue: []
};

let lastFetchedLyricsId = "";

function fetchLyrics(id) {
    if (!id) return;
    fetch(`http://127.0.0.1:10767/api/v2/lyrics/${id}`, {
        headers: { "apptoken": TOKEN }
    })
    .then(res => res.json())
    .then(payload => {
        if (payload && payload.data && payload.data.lines) {
            console.log(JSON.stringify({ 
                __type: "lyrics", 
                synced: true, 
                isCiderV2: true,
                lines: payload.data.lines.map(l => ({ time: l.start, text: l.text || "" }))
            }));
        } else {
            console.log(JSON.stringify({ __type: "lyrics", synced: false, isCiderV2: true, lines: [] }));
        }
    })
    .catch(() => {
        console.log(JSON.stringify({ __type: "lyrics", synced: false, isCiderV2: true, lines: [] }));
    });
}

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
            state.trackId = data.info.playParams && data.info.playParams.id ? data.info.playParams.id : "";
            state.length = Math.floor((data.info.durationInMillis || 0) * 1000); 
            state.shuffleMode = data.info.shuffleMode || 0;
            state.repeatMode = data.info.repeatMode || 0;
            state.inFavorites = !!data.info.inFavorites;
            
            if (state.trackId && state.trackId !== lastFetchedLyricsId) {
                lastFetchedLyricsId = state.trackId;
                fetchLyrics(state.trackId);
            }
            
            printState();
        }
    }).catch(() => {});
}

function fetchConfig() {
    fetch("http://127.0.0.1:10767/api/v2/config", {
        headers: { "apptoken": TOKEN }
    }).then(res => res.json()).then(data => {
        if (data && data.data && data.data.audio) {
            console.log(JSON.stringify({ __type: "config", audio: data.data.audio }));
        }
    }).catch(() => {});
}

function toggleAudioFeature(feature, state) {
    let payload = { enabled: state === 'true' };
    if (feature === 'atmos') {
        payload.binaural = state === 'true';
    }
    
    fetch(`http://127.0.0.1:10767/api/v2/audio/${feature}`, {
        method: "PATCH",
        headers: {
            "apptoken": TOKEN,
            "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
    }).then(() => fetchConfig()).catch(() => {});
}

socket.on("connect", () => {
    updateNowPlaying();
    updateQueue();
    updateVolume();
    fetchConfig();
});

// Poll volume and config periodically since Cider does not emit socket events for them
setInterval(() => {
    if (socket.connected) {
        updateVolume();
        fetchConfig();
    }
}, 3000);

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

function updatePlaylists() {
    fetch("http://127.0.0.1:10767/api/v1/amapi/run-v3", {
        method: "POST",
        headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
        body: JSON.stringify({ "path": "/v1/me/library/playlists" })
    }).then(res => res.json()).then(data => {
        let playlists = [];
        if (data.data && data.data.data && Array.isArray(data.data.data)) {
            playlists = data.data.data.map(p => {
                const attr = p.attributes || {};
                return {
                    id: p.id,
                    type: p.type || "library-playlists",
                    href: p.href || ("/v1/me/library/playlists/" + p.id),
                    name: attr.name || "",
                    artwork: attr.artwork ? attr.artwork.url.replace("{w}", "600").replace("{h}", "600") : "",
                    dateAdded: attr.dateAdded || ""
                };
            });
        }
        console.log(JSON.stringify({ __type: "playlists", results: playlists }));
    }).catch((e) => {
        console.error("Playlists error:", e);
    });
}

function updateForYou() {
    fetch("http://127.0.0.1:10767/api/v1/amapi/run-v3", {
        method: "POST",
        headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
        body: JSON.stringify({ "path": "/v1/me/recommendations" })
    }).then(res => res.json()).then(data => {
        let categories = [];
        if (data.data && data.data.data) {
            categories = data.data.data.map(group => {
                const title = group.attributes && group.attributes.title ? group.attributes.title.stringForDisplay : "Recommendations";
                let items = [];
                if (group.relationships && group.relationships.contents && group.relationships.contents.data) {
                    items = group.relationships.contents.data.map(p => {
                        const attr = p.attributes || {};
                        return {
                            id: p.id,
                            type: p.type || "playlists",
                            href: p.href || "",
                            name: attr.name || "",
                            artwork: attr.artwork ? attr.artwork.url.replace("{w}", "600").replace("{h}", "600") : "",
                            dateAdded: attr.dateAdded || ""
                        };
                    });
                }
                return {
                    title: title,
                    items: items
                };
            }).filter(c => c.items.length > 0);
        }
        console.log(JSON.stringify({ __type: "forYou", results: categories }));
    }).catch((e) => {
        console.error("For You error:", e);
    });
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
    } else if (line.startsWith("search ")) {
        const rawQuery = line.substring(7).trim();
        let apiQuery = rawQuery;
        let artistFilter = null;
        let albumFilter = null;
        
        // Extract artist=XYZ or artist:XYZ
        const artistMatch = rawQuery.match(/artist[=:]("([^"]+)"|([^\s]+))/i);
        if (artistMatch) {
            artistFilter = (artistMatch[2] || artistMatch[3]).toLowerCase();
            apiQuery = apiQuery.replace(artistMatch[0], "").trim();
        }

        // Extract album=XYZ or album:XYZ
        const albumMatch = rawQuery.match(/album[=:]("([^"]+)"|([^\s]+))/i);
        if (albumMatch) {
            albumFilter = (albumMatch[2] || albumMatch[3]).toLowerCase();
            apiQuery = apiQuery.replace(albumMatch[0], "").trim();
        }
        
        // If they only typed the filters, use them as the search term
        if (apiQuery.length === 0) {
            apiQuery = (artistFilter || "") + " " + (albumFilter || "");
            apiQuery = apiQuery.trim();
        }
        
        fetch("http://127.0.0.1:10767/api/v1/amapi/run-v3", {
            method: "POST",
            headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
            body: JSON.stringify({ "path": "/v1/catalog/us/search?term=" + encodeURIComponent(apiQuery) + "&types=songs&limit=25" })
        }).then(res => res.json()).then(data => {
            let results = [];
            try {
                if (data.data && data.data.results && data.data.results.songs && data.data.results.songs.data) {
                    results = data.data.results.songs.data.map(song => {
                        const attr = song.attributes || {};
                        return {
                            id: song.id || (attr.playParams ? attr.playParams.id : ""),
                            name: attr.name || "",
                            artistName: attr.artistName || "",
                            albumName: attr.albumName || "",
                            durationInMillis: attr.durationInMillis || 0,
                            contentRating: attr.contentRating || "",
                            audioTraits: attr.audioTraits || [],
                            artwork: attr.artwork ? attr.artwork.url.replace("{w}", "600").replace("{h}", "600") : ""
                        };
                    });
                    
                    if (artistFilter) {
                        results = results.filter(r => r.artistName.toLowerCase().includes(artistFilter));
                    }
                    if (albumFilter) {
                        results = results.filter(r => r.albumName.toLowerCase().includes(albumFilter));
                    }
                }
            } catch (e) {}
            console.log(JSON.stringify({ __type: "search", results: results }));
        }).catch((e) => { console.error("Search error:", e); });
    } else if (line.startsWith("playTrack ")) {
        const id = line.split(" ")[1];
        fetch("http://127.0.0.1:10767/api/v1/playback/play-item", {
            method: "POST",
            headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
            body: JSON.stringify({ "type": "songs", "id": id })
        }).then(() => {
            updateNowPlaying();
            updateQueue();
        }).catch(() => {});
    } else if (line.trim() === "queue") {
        updateQueue();
    } else if (line.trim() === "fetchConfig") {
        fetchConfig();
    } else if (line.startsWith("toggleAudioFeature ")) {
        let parts = line.split(" ");
        if (parts.length === 3) {
            toggleAudioFeature(parts[1], parts[2]);
        }
    } else if (line.trim() === "playlists") {
        updatePlaylists();
    } else if (line.trim() === "foryou") {
        updateForYou();
    } else if (line.startsWith("playPlaylist ")) {
        const parts = line.trim().split(" ");
        const type = parts.length >= 3 ? parts[1] : "library-playlists";
        const id = parts.length >= 3 ? parts[2] : parts[1];
        fetch("http://127.0.0.1:10767/api/v1/playback/play-item", {
            method: "POST",
            headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
            body: JSON.stringify({ "type": type, "id": id })
        }).then(() => fetch("http://127.0.0.1:10767/api/v1/playback/play", { method: "POST", headers: { "apptoken": TOKEN }}))
        .then(() => {
            updateNowPlaying();
            updateQueue();
        }).catch(() => {});
    } else if (line.startsWith("playlistTracks ")) {
        const href = line.substring(15).trim();
        let allTracks = [];
        
        function fetchPage(path) {
            fetch("http://127.0.0.1:10767/api/v1/amapi/run-v3", {
                method: "POST",
                headers: { "apptoken": TOKEN, "Content-Type": "application/json" },
                body: JSON.stringify({ "path": path })
            })
            .then(r => r.json())
            .then(data => {
                if (data && data.data && data.data.data) {
                    const tracks = data.data.data.map(song => {
                        const attr = song.attributes || {};
                        return {
                            id: song.id || (attr.playParams ? attr.playParams.id : ""),
                            name: attr.name || "",
                            artistName: attr.artistName || "",
                            albumName: attr.albumName || "",
                            durationInMillis: attr.durationInMillis || 0,
                            contentRating: attr.contentRating || "",
                            audioTraits: attr.audioTraits || [],
                            artwork: attr.artwork ? attr.artwork.url.replace("{w}", "600").replace("{h}", "600") : ""
                        };
                    });
                    allTracks = allTracks.concat(tracks);
                }
                
                if (data && data.data && data.data.next) {
                    // Apple Music API provides the exact path needed for the next page
                    fetchPage(data.data.next);
                } else {
                    // Done fetching all pages
                    console.log(JSON.stringify({ __type: "playlistTracks", results: allTracks }));
                }
            })
            .catch(e => {
                console.error("Error fetching playlist tracks", e);
                // Print whatever we managed to fetch before failing
                console.log(JSON.stringify({ __type: "playlistTracks", results: allTracks }));
            });
        }
        
        // Start fetching the first page with the max limit per request
        fetchPage(href + "/tracks?limit=100");
    }
});
