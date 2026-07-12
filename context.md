# REFLECTION - Quickshell Project Context

This file serves as the memory and context payload for future sessions to seamlessly continue the development of the REFLECTION Quickshell environment.

## Current State & Architecture
- **Framework:** Quickshell (Wayland-based QML desktop shell).
- **Core Design Philosophy:** A sleek, "void-like" ambient aesthetic. Combines deep dark backgrounds with ethereal, glassmorphic "Electric Blue" shimmers. Highly dynamic animations, but rigidly built for ultra-performance (zero-lag on both AMD and proprietary NVIDIA Wayland drivers).
- **Wayland Protocols:** Utilizing native `Quickshell.Wayland` for layer shells (`PanelWindow`), `ext-session-lock-v1` (`WlSessionLock`), and `wlr-screencopy` for visual captures.

## Major Components Implemented

### 1. Ambient Idle State (`ui/panels/ambient_idle/`)
- **Concept:** A calm, immersive void state that activates during inactivity.
- **Starfield & Falling Stars:** Features heavily optimized, randomized native QML properties to simulate a deep space effect (`Starfield.qml` and `FallingStars.qml`) without relying on expensive `Canvas` or `Qt5Compat.GraphicalEffects` which choked the NVIDIA driver. 
- **Idle Visualizer:** A glowing, ethereal audio visualizer that gently pulses with random data to keep the screen dynamic but relaxing.

### 2. Music & Idle Visualizers (`ui/components/MusicVisualizer.qml`)
- **Aurora Beams:** Replaced basic rectangles with native QML `Rectangle` vertical gradients, rendering beautiful light-beams that fade into the void.
- **Floating Star Caps:** Physics-based glowing dots that sit on top of the bars, popping up on audio hits and floating back down smoothly.
- **Performance Architecture (CRITICAL):** 
  - *No individual listeners!* Previously, 137+ individual bars were subscribed to the `CavaService` and running independent `Timer`s, flooding the CPU with 8,200+ Javascript executions per second.
  - *Centralized Controller:* The architecture was rewritten to use exactly **one** Root `Connections` and **one** Root `Timer` that loops through a `Repeater`, bringing the JS execution down to 60 calls per second and instantly un-bottlenecking the GPU.
  - *Native QML:* Completely purged `LinearGradient` and `RadialGradient` from `GraphicalEffects`, using raw QML `Rectangle { gradient: Gradient{} }` to ensure butter-smooth 60fps on NVIDIA.

### 3. The Unified Taskbar & Start Menu (`ui/panels/taskbar/`, `ui/panels/launcher/`)
- **Taskbar:** An auto-hiding base panel spanning the bottom of the screen.
- **Start Menu (Fused):** Extracted from a standalone floating window into `StartMenuUI.qml`. Embedded seamlessly into the taskbar layout using structural "swoop" fillets to look physically connected. 
- **App Grid Physics:** Highly interactive `AppGrid.qml` featuring custom category filtering, staggered fade-in animations, ambient hover effects, and scale compression.

### 4. The Dynamic Island (`ui/panels/dynamic_island/`)
- **State Machine:** Fluidly scales between states: `Minimized (0)`, `Hovered (1)`, `Expanded (2)`, `Notification (3)`, `History (4)`, `OSD (5)`.
- **Architectural Shift:** Core logic resides in `DynamicIslandWidget.qml` (inheriting `Item`) to bypass Wayland's security rules, allowing the Island to be injected into both the desktop layer-shell and the lockscreen surface simultaneously.
- **Features:** MPRIS Media Controls, Notification popups, Notification History, System OSDs.

### 5. Screenshot Utility (`ui/panels/screenshot/`)
- **Pipeline:** GlobalShortcut/IPC -> Force closes StartMenu -> Opens `RegionSelection.qml` (Overlay layer).
- **Architecture:** Uses Quickshell's native `ScreencopyView` to instantly freeze the GPU output as a canvas.
- **Race Condition Fix:** A bash script fires `sleep 0.3 && grim` to wait for the UI overlays and crosshair cursor to completely disappear before taking the perfect snip.

### 6. The Lockscreen (`ui/panels/lockscreen/`)
- **Backend:** Powered by `Quickshell.Services.Pam`. Uses asynchronous request/response loops to safely pass the cached password to the PAM module.
- **Aesthetics:** Windows 11 style pill-shaped password field. Uses `OpacityMask` to flawlessly circular-crop the user avatar. Features a locked-down version of the Dynamic Island injected directly into the surface.

## Known Limitations & Solutions Overcome
1. **Window Resizing Lag:** Wayland `PanelWindow` cannot bind `implicitWidth` to an animating property. **Solution:** Hardcoded bounds and animated the QML `Item` inside.
2. **Lockscreen UI Nesting:** Wayland forbids nesting a Layer Shell window inside a Lockscreen. **Solution:** Refactored Dynamic Island into an inheritable Widget.
3. **NVIDIA Wayland Stuttering:** Hundreds of `Qt5Compat.GraphicalEffects` choked the proprietary driver. **Solution:** Rewrote all shaders into pure native `Rectangle` gradients and radii.
4. **Visualizer Sluggishness (JS CPU Flood):** 137 individual CAVA listeners bottlenecked the QML engine. **Solution:** Centralized the listener to a single root controller.

## Next Steps / Future Roadmap
- Fleshing out the individual Control Center panels (Wi-Fi, Bluetooth).
- Formalizing a workspace/desktop switcher into the taskbar.
- Integrating `awww` formally for global wallpaper management across the desktop and the lockscreen.
