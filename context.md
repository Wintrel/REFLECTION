# REFLECTION - Quickshell Project Context

This file serves as the memory and context payload for future sessions to seamlessly continue the development of the REFLECTION Quickshell environment.

## Current State & Architecture
- **Framework:** Quickshell (Wayland-based QML desktop shell).
- **Core Design:** MacOS/iOS inspired "Dynamic Island" combined with Windows 11 / Modern Linux aesthetics. Heavy use of glassmorphism (`FastBlur`, `OpacityMask`), smooth `SpringAnimation` physics, and a dark/neon color palette (`#0a0a0e`, `#710cee`, `#00FFCC`).
- **Wayland Protocols:** Utilizing native `Quickshell.Wayland` for layer shells (`PanelWindow`) and `ext-session-lock-v1` (`WlSessionLock`).

## Major Components Implemented

### 1. The Dynamic Island (`ui/panels/dynamic_island/`)
- **State Machine:** Fluidly scales between states: `Minimized (0)`, `Hovered (1)`, `Expanded (2)`, `Notification (3)`, `History (4)`, `OSD (5)`.
- **Architectural Shift:** Initially a `PanelWindow`, the core logic was extracted into `DynamicIslandWidget.qml` (inheriting `Item`). This was a crucial refactor to bypass Wayland's security rules, allowing the Island to be injected into both the desktop layer-shell and the lockscreen surface simultaneously.
- **Features:** 
  - MPRIS Media Controls (Play, Pause, Skip, visualizer, interactive progress bar).
  - Notification popups (`NotificationContent.qml`) with auto-dismiss timers.
  - Notification History (`NotificationHistoryContent.qml`) storing past alerts globally in `State.GlobalStates.notificationHistory`.
  - System OSDs (Volume/Brightness indicators).

### 2. The Lockscreen (`ui/panels/lockscreen/`)
- **Backend:** Powered by `Quickshell.Services.Pam` using the `hyprlock` config. It uses asynchronous request/response loops (`onResponseRequiredChanged`) to safely pass the cached password to the PAM module.
- **Wayland Surface:** `WlSessionLock` blocks the screen. It dynamically spawns `LockscreenUI.qml` delegates for each monitor.
- **Communication:** Because `LockscreenUI` delegates are dynamic, communication between `PamContext` and the UI relies on a robust `Connections`/Signal-Slot pattern broadcasted from `root` (`authSuccess`, `authFailed`, `pamMessage`).
- **Aesthetics (`LockscreenUI.qml`):**
  - Features a stunning blurred version of the desktop wallpaper (`FastBlur`) with a darkening overlay.
  - Smooth parallax scale transitions between `PassiveState` (clock view, `scale: 0.95`) and `AuthState` (password input view, `scale: 1.05`).
  - **PassiveState:** Massive, thin elegant clock typography and an injected `DynamicIslandWidget { isLocked: true }` that blocks interaction and censors notification contents for privacy.
  - **AuthState:** Windows 11 style pill-shaped password field with perfectly spaced `●` dots.
  - **Avatar (`avatarImg`):** Automatically pulls the user's profile picture from `~/.face.icon` (which is a symlink to `/var/lib/AccountsService/icons/$USER`), using `OpacityMask` to give it a perfectly hardware-accelerated circular crop.

### 3. Core Services & Themes (`core/`)
- `Theme.qml`: Global constants for colors, animation durations (`animDuration: 600`), and Island geometry limits.
- **Global States:** `State.GlobalStates` acts as a central singleton for persisting data like the notification history list model.

## Known Limitations & Solutions Overcome
1. **Window Resizing Lag:** Wayland `PanelWindow` cannot bind `implicitWidth` to an animating property without massive 60FPS compositor lag. **Solution:** Hardcoded the `PanelWindow` bounds to `Math.max(theme.islandMaxW)` and animated the QML `Item` *inside* the static transparent canvas.
2. **Lockscreen UI Nesting:** Wayland forbids nesting a Layer Shell window inside a Lockscreen surface. **Solution:** Refactored `DynamicIsland.qml` into `DynamicIslandWidget.qml` to decouple the QML component from the Wayland `PanelWindow` shell.
3. **Circular Avatar Clipping:** QML's `clip: true` only clips to bounding boxes, ignoring `radius`. **Solution:** Employed `OpacityMask` from `Qt5Compat.GraphicalEffects` for flawless rounded corners.

## Next Steps / Future Roadmap
- Expanding the Taskbar components (`ui/panels/taskbar/`) and unifying their aesthetic with the Island.
- Integrating `awww` formally for global wallpaper management across the desktop and the lockscreen.
- Polishing system tray / battery indicators.
