# REFLECTION - Quickshell Project Context

This file serves as the memory and context payload for future sessions to seamlessly continue the development of the REFLECTION Quickshell environment.

## Current State & Architecture
- **Framework:** Quickshell (Wayland-based QML desktop shell).
- **Core Design Philosophy:** A sleek, "OLED Ghostly Stardust" ambient aesthetic inspired by the user's OC. Deep void backgrounds with soft silver-lavender interactive elements and muted cosmic slates.
- **Performance Constraints:** Highly dynamic animations, but rigidly built for ultra-performance (zero-lag on both AMD and proprietary NVIDIA Wayland drivers) and OLED safety (true blacks, anti-burn-in elements).
- **Wayland Protocols:** Utilizing native `Quickshell.Wayland` for layer shells (`PanelWindow`), `ext-session-lock-v1` (`WlSessionLock`), and `wlr-screencopy` for visual captures.

## Major Components Implemented

### 1. Ambient Idle State (`ui/panels/ambient_idle/`)
- **Concept:** A calm, immersive void state that activates during inactivity.
- **Starfield & Falling Stars:** Features heavily optimized, randomized native QML properties to simulate a deep space effect.
- **Idle Visualizer:** A glowing, ethereal visualizer. Features a native QML sweeping shimmer that illuminates floating star caps.
- **OLED Safety (CRITICAL):** The floating star caps are mathematically bound to the shimmer overlay opacity and frequently drop to 0 height, ensuring they are completely invisible 90% of the time to prevent OLED static burn-in.

### 2. Music & Idle Visualizers (`ui/components/MusicVisualizer.qml` & `IdleVisualizer.qml`)
- **Aesthetics:** Aurora light beams using native QML vertical gradients, capped with physics-based glowing stars.
- **Performance Architecture (The Hybrid Fix):** 
  - *Zero JS Sweep:* Replaced Javascript property bindings tied to a 60fps sweep animation with native QML `SequentialAnimation`. This eliminated 8,200+ Javascript executions per second that were previously flooding the CPU.
  - *Centralized CAVA Listener:* Uses exactly **one** Root `Connections` to `CavaService` to prevent overwhelming QML's signal dispatcher with 137 individual 60Hz handlers.
  - *Individual Mock Timers:* Restored 137 individual `Timer`s inside the bars with prime-number offset intervals (1500ms, 1900ms, etc.) to recreate a beautifully chaotic, organic phase drift when idle. (Turns out, ~70 timer executions a second is virtually free!).
  - *CAVA Interpolation:* Re-enabled `Behavior on targetHeight` with `duration: 60` and `Easing.OutQuad` specifically when CAVA is active so the bars perfectly glide between audio frames instead of rigidly snapping. Disabled `capHeight` behavior during CAVA to prevent "double-smoothing" lag.

### 3. Edge Lighting (`ui/panels/edge_lighting/`)
- **GPU Optimization:** Completely purged `GaussianBlur` and `OpacityMask` from `GraphicalEffects`, using raw QML `Rectangle { gradient: Gradient{} }` and container clipping to ensure butter-smooth 60fps on NVIDIA. (Note: Currently reverted by user preference due to clipping artifacts, but architecture is proven).

### 4. The Unified Taskbar & Start Menu (`ui/panels/taskbar/`, `ui/panels/launcher/`)
- **Taskbar:** An auto-hiding base panel spanning the bottom of the screen.
- **Start Menu (Fused):** Extracted from a standalone floating window into `StartMenuUI.qml`. Embedded seamlessly into the taskbar layout using structural "swoop" fillets to look physically connected. 
- **App Grid Physics:** Highly interactive `AppGrid.qml` featuring custom category filtering, staggered fade-in animations, ambient hover effects, and scale compression.

### 5. The Dynamic Island (`ui/panels/dynamic_island/`)
- **State Machine:** Fluidly scales between states: `Minimized (0)`, `Hovered (1)`, `Expanded (2)`, `Notification (3)`, `History (4)`, `OSD (5)`.
- **Architectural Shift:** Core logic resides in `DynamicIslandWidget.qml` (inheriting `Item`) to bypass Wayland's security rules, allowing the Island to be injected into both the desktop layer-shell and the lockscreen surface simultaneously.
- **Features:** MPRIS Media Controls, Notification popups, Notification History, System OSDs.

### 6. Screenshot Utility (`ui/panels/screenshot/`)
- **Pipeline:** GlobalShortcut/IPC -> Force closes StartMenu -> Opens `RegionSelection.qml` (Overlay layer).
- **Architecture:** Uses Quickshell's native `ScreencopyView` to instantly freeze the GPU output as a canvas.
- **Race Condition Fix:** A bash script fires `sleep 0.3 && grim` to wait for the UI overlays and crosshair cursor to completely disappear before taking the perfect snip.

### 7. The Lockscreen (`ui/panels/lockscreen/`)
- **Backend:** Powered by `Quickshell.Services.Pam`. Uses asynchronous request/response loops to safely pass the cached password to the PAM module.
- **Aesthetics:** Windows 11 style pill-shaped password field. Uses `OpacityMask` to flawlessly circular-crop the user avatar. Features a locked-down version of the Dynamic Island injected directly into the surface.

## Known Limitations & Solutions Overcome
1. **Window Resizing Lag:** Wayland `PanelWindow` cannot bind `implicitWidth` to an animating property. **Solution:** Hardcoded bounds and animated the QML `Item` inside.
2. **Lockscreen UI Nesting:** Wayland forbids nesting a Layer Shell window inside a Lockscreen. **Solution:** Refactored Dynamic Island into an inheritable Widget.
3. **NVIDIA Wayland Stuttering:** Hundreds of `Qt5Compat.GraphicalEffects` choked the proprietary driver. **Solution:** Rewrote shaders into pure native `Rectangle` gradients and radii where possible.
4. **Visualizer Sluggishness (JS CPU Flood):** 137 individual JS bindings tied to a 60fps sweep bottlenecked the QML engine. **Solution:** Purged JS bindings in favor of native `SequentialAnimation`.
5. **OLED Visualizer Burn-In:** Static idle items damage OLEDs. **Solution:** Bound idle star opacity directly to the sweeping shimmer and forced frequent height drops to 0 to keep them invisible 90% of the time.

## Next Steps / Future Roadmap
- Fleshing out the individual Control Center panels (Wi-Fi, Bluetooth).
- Formalizing a workspace/desktop switcher into the taskbar.
- Integrating `awww` formally for global wallpaper management across the desktop and the lockscreen.
