# Cider Hub - Development Context & Progress

This document summarizes the current state, architecture, and recent fixes for the **Cider Hub** (Dynamic Island Ultra-Expanded State `13`) in the Quickshell Reflection widget.

## Architecture Overview
The Cider Hub is a rich media interface for controlling the Cider Apple Music client.
- **Backend (`scripts/cider_daemon.js`)**: A Node.js daemon that connects to Cider's IPC socket (`http://127.0.0.1:10767`) using `socket.io-client`. It listens for events (`API:Playback`) and issues REST API calls to fetch queue, playback state, search, and lyrics.
- **Service (`core/services/media/CiderService.qml`)**: A Quickshell QML Singleton that wraps the `cider_daemon.js` process via a `Process` block. It uses `SplitParser` to read JSON packets from `stdout` and maps them to QML properties.
- **UI (`ui/panels/dynamic_island/components/CiderHubContent.qml`)**: The main container for the Cider Hub. It manages tab routing between:
  - Tab 0: Up Next Queue (`CiderQueue.qml`)
  - Tab 1: Search (`CiderSearch.qml`)
  - Tab 2: Lyrics (`CiderLyrics.qml`)

## Recent Fixes & Implementations

### 1. LRCLIB Synced Lyrics Integration
- **Problem**: Cider's internal lyrics API was difficult to authenticate or unreliable.
- **Solution**: Implemented a fallback to the public **LRCLIB API** inside `cider_daemon.js`.
- **Flow**: Whenever the track changes, the daemon queries LRCLIB using the track title and artist. It pushes the parsed `[mm:ss.xx]` synced lyrics JSON to `CiderService.qml`.
- **UI Polish**: Fixed a bug where `mprisPlayer` wasn't passed into `CiderLyrics.qml`. Added a buttery-smooth auto-scroll in `CiderLyrics.qml` using a `contentY` `NumberAnimation` (600ms OutQuart easing) that gracefully suspends itself when the user is actively flicking or dragging the view.

### 2. Up Next Queue Skipping (The 350ms Fix)
- **Problem**: Jumping to a specific song in the Up Next queue is tricky because Cider's REST API doesn't expose a clean `/skip-to-queue-index` endpoint. Using `play-item` destroyed the queue context entirely, leaving the queue empty.
- **Solution**: Reverted the queue click handler in `CiderQueue.qml` to use `skipToId(id)`.
- **Backend Fix**: `cider_daemon.js` calculates the distance between the current song and the target song in the queue, then fires a loop of `next` or `previous` REST requests. To prevent Cider from dropping these requests due to rate-limiting/spam, a strict `350ms` delay was introduced between each internal `fetch()` call.

### 3. Visualizer Conflict & Freeze Fix
- **Problem**: When morphing from the normal media player (`ExpandedContent.qml`) to the Cider Hub (`CiderHubContent.qml`), the background audio visualizer would freeze and lag out.
- **Cause**: Both components instantiate a `Components.MusicVisualizer`. Both used a QML `Binding` to toggle `CavaService.active`. During the fade animation, the old visualizer would fade out *after* the new one faded in, causing the old visualizer's `Binding` to shut down the Cava process, overriding the new visualizer.
- **Solution**: Refactored `CavaService.qml` and `MusicVisualizer.qml`. Removed the `Binding` and replaced it with a reference-counted `request()` and `release()` system. As long as `requestCount > 0`, the Cava process stays alive.

## Known Quirks / Next Steps
- **Queue Initialization**: If the queue goes blank (e.g., from accidentally triggering a queue-wiping context like `play-item`), the user must completely restart Cider to unfreeze the internal queue manager and start a new playlist.
- **Search**: The search uses Apple Music's `run-v3` endpoint. It currently filters by Artist/Album if `artist=` or `album=` is typed in the query.
