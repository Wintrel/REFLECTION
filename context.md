# REFLECTION - Quickshell Project Context

This file serves as the memory and context payload for future sessions to seamlessly continue the development of the REFLECTION Quickshell environment.

## Current State & Architecture
- **Framework:** Quickshell (Wayland-based QML desktop shell).
- **Core Design Philosophy:** Abandoned heavy glassmorphism for a sleek, ultra-performant **solid dark aesthetic** (`#000000`, `#0a0a0e`) inspired by minimalist futuristic styling. Accents use a high-contrast neon purple (`#710cee`) for structural borders and a signature neon orange (`#ff9900`) strictly for interactive physics and feedback.
- **Wayland Protocols:** Utilizing native `Quickshell.Wayland` for layer shells (`PanelWindow`), `ext-session-lock-v1` (`WlSessionLock`), and `wlr-screencopy` for visual captures.

## Major Components Implemented

### 1. The Unified Taskbar & Start Menu (`ui/panels/taskbar/`, `ui/panels/launcher/`)
- **Taskbar:** An auto-hiding base panel that spans the bottom of the screen.
- **Start Menu (Fused):** Extracted from a standalone floating window into `StartMenuUI.qml`. It embeds seamlessly into the taskbar layout using structural "swoop" fillets to look physically connected. 
- **App Grid Physics:** Highly interactive `AppGrid.qml` featuring custom category filtering (`All`, `Internet`, `Games`, etc.), staggered 300ms fade-in animations, `RectangularGlow` ambient orange hover effects, and scale compression on click.
- **Control Center:** Connected to the right side of the taskbar, containing quick toggles and sliders.

### 2. The Dynamic Island (`ui/panels/dynamic_island/`)
- **State Machine:** Fluidly scales between states: `Minimized (0)`, `Hovered (1)`, `Expanded (2)`, `Notification (3)`, `History (4)`, `OSD (5)`.
- **Architectural Shift:** Core logic resides in `DynamicIslandWidget.qml` (inheriting `Item`) to bypass Wayland's security rules, allowing the Island to be injected into both the desktop layer-shell and the lockscreen surface simultaneously.
- **Features:** MPRIS Media Controls, Notification popups, Notification History, System OSDs.

### 3. Screenshot Utility (`ui/panels/screenshot/`)
- **Pipeline:** Activated via GlobalShortcut/IPC -> Force closes StartMenu to steal Wayland keyboard focus -> Opens `RegionSelection.qml` (Overlay layer).
- **Architecture:** Uses Quickshell's native `ScreencopyView` to instantly freeze the GPU output as a canvas. The user draws a bounding box over it.
- **Race Condition Fix:** When the Region Selector is dismissed, a bash script fires `sleep 0.3 && grim` to wait for the UI overlays and crosshair cursor to completely disappear before taking the perfect snip.

### 4. The Lockscreen (`ui/panels/lockscreen/`)
- **Backend:** Powered by `Quickshell.Services.Pam`. Uses asynchronous request/response loops to safely pass the cached password to the PAM module.
- **Aesthetics:** Windows 11 style pill-shaped password field. Uses `OpacityMask` to flawlessly circular-crop the user avatar (`~/.face.icon`). Features a completely locked-down version of the Dynamic Island injected directly into the surface.

## Known Limitations & Solutions Overcome
1. **Window Resizing Lag:** Wayland `PanelWindow` cannot bind `implicitWidth` to an animating property. **Solution:** Hardcoded `PanelWindow` bounds and animated the QML `Item` *inside* the static transparent canvas.
2. **Lockscreen UI Nesting:** Wayland forbids nesting a Layer Shell window inside a Lockscreen. **Solution:** Refactored `DynamicIsland.qml` into `DynamicIslandWidget.qml`.
3. **Screenshot Crosshair Bleed:** `grim` captured the UI overlay and the Wayland crosshair. **Solution:** A 0.3s delay pipeline ensures the overlay is fully closed before capture.

## Next Steps / Future Roadmap
- Fleshing out the individual Control Center panels (Wi-Fi, Bluetooth).
- Formalizing a workspace/desktop switcher into the taskbar.
- Integrating `awww` formally for global wallpaper management across the desktop and the lockscreen.
