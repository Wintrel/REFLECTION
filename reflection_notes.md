# Reflection Dynamic Island – Hybrid Ambient Status System

## Design Goal

The Dynamic Island should function as an ambient status object rather than a miniature dashboard.

Unlike Apple's implementation, Reflection does not aim to constantly display application content. Instead, it provides subtle awareness of system activity while remaining visually calm and unobtrusive.

The island should feel like a living part of the desktop environment that quietly communicates state without demanding attention.

---

## Core Philosophy

Reflection follows the same principles used throughout BLOOM:

* Show only what is necessary.
* Allow deeper information when requested.
* Preserve user context.
* Prioritize consistency over visual complexity.
* Use animation to communicate state changes, not decoration.

The minimized state should answer a simple question:

"What should the user be aware of right now?"

Not:

"What information can we fit into this space?"

---

## Minimized States

### Idle State

When no active music or unread notifications exist, the island enters its smallest form.

Purpose:

* Indicate the system is available.
* Reduce visual weight.
* Avoid occupying unnecessary attention.

Behavior:

* Small pill shape.
* Minimal animation.
* Nearly disappears into the desktop.

---

### Music State

When music is playing, the island provides a subtle indication rather than full media controls.

Possible indicators:

* Tiny animated waveform.
* Small circular audio activity indicator.
* Minimal progress ring.

Avoid:

* Large album artwork.
* Song titles.
* Full media controls.

Reason:
The user only needs to know that music is active. Detailed information remains available when expanded.

---

### Notification State

Unread notifications are represented through lightweight indicators.

Possible indicators:

* Notification dot.
* Small unread counter.
* Subtle glow pulse.

Avoid:

* Constantly changing application icons.
* Large badges.
* Full notification previews.

Reason:
The user only needs awareness that information is waiting.

---

### Combined State

When both music and notifications exist:

* Music indicator remains visible.
* Notification count remains visible.
* Layout remains compact.

Example:

Waveform + Notification Count

Rather than:

Album Art + App Icon + Multiple Badges

The goal is recognition, not information density.

---

## Expanded States

The minimized island never attempts to replace expanded views.

Detailed information remains available through expansion:

Music State:

* Album artwork
* Playback controls
* Song information

Notification State:

* Notification history
* Application source
* Notification actions

This separation keeps the minimized state calm while allowing powerful functionality when requested.

---

## Context Preservation

The Dynamic Island should remember the state it interrupted.

Example:

Music Expanded
↓
Notification Arrives
↓
Notification Shown
↓
Notification Dismissed
↓
Return To Music

The system should respect user intent and restore the previous context whenever possible.

---

## Visual Identity

Reflection's Dynamic Island should feel:

* Calm
* Responsive
* Ambient
* Minimal
* Consistent

The island should never become the center of attention.

It should feel like a quiet companion that communicates system activity through subtle motion and state changes.

The user notices it when needed and forgets about it when not.
