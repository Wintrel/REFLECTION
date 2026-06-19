# Reflection – OSD & Notification Priority System

## Purpose

Reflection uses a priority-based notification and OSD system to ensure information is communicated appropriately without becoming distracting.

Not all events should receive the same level of visual or audio attention.

The goal is to provide awareness while preserving Reflection's calm and ambient user experience.

---

# Design Principles

* Show only what is necessary.
* Match feedback intensity to event importance.
* Avoid alert fatigue.
* Use animation as primary feedback.
* Reserve stronger sounds and visuals for important events.
* Keep OSDs temporary and lightweight.
* Keep notifications distinct from OSDs.

---

# Event Categories

## Tier 1 – Informational

Informational events are simple confirmations.

These events do not require action and exist only to inform the user that something occurred successfully.

### Examples

* Volume changed
* Brightness changed
* Charger connected
* Charger disconnected
* Bluetooth device connected
* Bluetooth device disconnected
* Wi-Fi connected
* Wi-Fi disconnected

### Behavior

* Short display duration (1–2 seconds)
* Compact island expansion
* Soft transition animations
* Optional subtle sound
* Not stored in notification history

### Examples

Volume 75%

Brightness 50%

Charging

Connected

Headphones Connected
`
---

## Tier 2 – Attention

Attention events are situations the user should be aware of soon but do not require immediate action.

### Examples

* Battery reaches 20%
* Wi-Fi connection lost unexpectedly
* Bluetooth device disconnected unexpectedly
* VPN disconnected

### Behavior

* Longer display duration (3–4 seconds)
* Slightly stronger visual presence
* More noticeable sound feedback
* Not overly intrusive

### Examples

Battery 20% Remaining

Connection Lost

Headphones Disconnected

---

## Tier 3 – Critical

Critical events require user action and should stand out more clearly.

These are the few situations where Reflection should actively seek user attention.

### Examples

* Battery reaches 10%
* Battery reaches 5%
* Critical system warnings
* Thermal warnings
* Critically low storage

### Behavior

* Longest display duration
* Distinct sound
* Stronger visual emphasis
* Possible repeat reminder if condition persists

### Examples

⚠ Battery Low – 10% Remaining

⚠ Battery Critical – 5% Remaining

---

# OSD Rules

OSDs provide temporary system feedback.

OSDs are not notifications.

OSDs should:

* Appear briefly
* Communicate state changes
* Never enter notification history
* Never increase notification counters
* Return to the previous island state after completion

### OSD Examples

* Volume
* Brightness
* Charging status
* Bluetooth connection
* Wi-Fi connection

---

# Notification Rules

Notifications represent information that may require later review.

Notifications should:

* Enter notification history
* Increase unread counters
* Support priority levels
* Respect context restoration

### Notification Examples

* Discord messages
* Email alerts
* Application notifications
* System notifications requiring review

---

# Context Restoration

Temporary interruptions should never destroy user context.

Example:

Music View Open
↓
Battery Warning Appears
↓
Battery Warning Dismisses
↓
Return To Music View

The island should always attempt to restore the state that was active before the interruption occurred.

---

# Scope for Reflection v1

The following OSDs are considered core functionality:

### Completed

* Volume OSD
* Brightness OSD

### Planned

* Charging Connected
* Charging Disconnected
* Battery 20%
* Battery 10%
* Battery 5%
* Wi-Fi Connected
* Wi-Fi Disconnected
* Bluetooth Connected
* Bluetooth Disconnected

After these are implemented, focus should shift to the Reflection Taskbar rather than expanding the island further.

The goal is refinement, not feature accumulation.
