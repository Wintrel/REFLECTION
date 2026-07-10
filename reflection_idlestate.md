# Reflection — Ambient Idle State (Concept)

### Overview

The Ambient Idle State is a non-locking desktop mode designed for periods of inactivity when the user is still nearby (e.g. making coffee, doing chores, or simply away from the desk).

Unlike a lock screen, Ambient Idle is not a security feature. It is a visual and power-conscious state that allows Reflection to become calmer while remaining immediately accessible.

The lock screen remains a manual action (Win + L).

---

# Design Philosophy

Reflection should acknowledge that there is a difference between:

* **Active** – user interacting with the desktop.
* **Idle** – user is temporarily away but still in the environment.
* **Locked** – user intentionally secured the computer.

The shell should adapt to the user's presence rather than immediately transitioning into a security state.

---

# Transition

After a configurable period of inactivity (for example 2–5 minutes):

```
Active Desktop
        │
        ▼
Reflection Ambient Idle
```

The transition should be smooth (approximately 300–600 ms) rather than instantaneous.

---

# Wallpaper

When Ambient Idle activates:

* Gradually reduce saturation.
* Slightly darken the wallpaper.
* Preserve the artwork (avoid full grayscale).
* Return to full color immediately when activity resumes.

Goal:

> Make the room feel calmer without making the desktop feel inactive.

---

## Ambient Visualizer (reuses the same visual design)

Ambient Idle uses a **dedicated procedural visualizer** rather than CAVA.

When Ambient Idle activates:

* Pause all active media playback.
* Stop CAVA entirely.
* Switch to Reflection's internal idle visualizer.
* The idle visualizer spans the full width of the desktop (across all connected displays when docked).
* Bars move slowly using procedural/randomized motion.
* Motion should resemble calm breathing rather than reacting to audio.
* Electric Blue shimmer occasionally travels across the bars as an ambient effect.

The idle visualizer exists independently of media playback and is intended purely to give Reflection a subtle sense of life.

---


# Ambient Shimmer

Reflection's Electric Blue shimmer becomes an ambient effect.

Instead of indicating loading:

* A slow shimmer travels across the idle visualizer.
* Animation should be infrequent and subtle.
* The shimmer represents Reflection remaining awake.

Meaning:

> Reflection is present.

---

# Multi-Monitor Mode

When multiple monitors are connected:

The ambient shimmer should travel continuously across all displays.

Example:

```
Laptop Display
━━━━━━━━━━━━━━━━━━━━▶

                     External Display
▶━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

The animation should continue seamlessly between monitors rather than restarting on each display.

Goal:

* Make the desktop feel like one continuous workspace.
* Reinforce Reflection as a unified shell.

---

# UI Behaviour

During Ambient Idle:

* Reduce overall UI emphasis.
* Lower opacity of non-essential widgets.
* Reduce visual noise.
* Preserve layout.
* Avoid hiding information.

Reflection should become quieter rather than disappearing.

---

# Performance Behaviour

Ambient Idle should reduce Reflection's workload where possible.

Possible optimizations:

* Lower animation refresh rates.
* Reduce sensor polling frequency.
* Pause unnecessary animations.
* Disable expensive visual effects while idle.

Goal:

* Lower CPU usage.
* Reduce GPU workload.
* Improve efficiency on battery-powered devices.

---

# OLED Considerations

Because Reflection primarily uses dark surfaces:

Ambient Idle can further reduce OLED power consumption by:

* Darkening wallpapers.
* Reducing bright accent colors.
* Limiting unnecessary animation.

Power saving is considered a secondary benefit rather than the primary goal.

---

# Wake Behaviour

Any user interaction immediately restores Reflection.

Examples:

* Mouse movement
* Keyboard input
* Touchpad gesture

Transition:

```
Ambient Idle
      │
Input detected
      ▼
Normal Reflection
```

The wake animation should feel instant while remaining visually smooth.

---

# Core Design Principle

Ambient Idle is **not** a screensaver.

It is Reflection entering a quieter, calmer state while waiting for the user to return.

The desktop remains alive, subtle, and visually cohesive without demanding attention.


## Media Behaviour

Entering Ambient Idle should automatically pause media playback.

This is primarily intended for the developer's personal workflow, where music is often unintentionally left playing after stepping away from the computer.

When Reflection exits Ambient Idle:

* The desktop returns to its normal state.
* Media **remains paused**.
* Playback resumes only when the user explicitly presses Play.

This avoids unexpected audio starting the moment the user returns.

