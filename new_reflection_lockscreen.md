REFLECTION – LOCKSCREEN ISLAND DESIGN NOTES

Core Philosophy

The lockscreen island is not a second desktop island.

It is a restricted sibling designed around awareness, authentication, and minimal interaction.

The desktop island acts as Reflection's Interaction Layer.

The lockscreen island acts as Reflection's Presence Layer.

Its purpose is to answer a simple question:

"What do I need to know or interact with before unlocking my system?"

Anything beyond that belongs to the desktop environment after authentication.

---

Design Goals

* Minimal and calm.
* No information overload.
* No system management.
* No control center functionality.
* No private notification content.
* Preserve Reflection's compact → expanded interaction philosophy.
* Always provide a visual indication that the system is alive and active.

The lockscreen island should feel quieter and more focused than the desktop island.

---

Lockscreen Island States

1. Idle State

Purpose:
Default state when no relevant activity exists.

Behavior:

* Smallest island size.
* Minimal visual presence.
* Serves as the island's resting state.

Represents:
"The system is idle."

---

2. Presence State

Purpose:
Indicates that background activity exists without exposing details.

Behavior:

* Shows minimal media activity indicator.
* Shows notification count badge.
* Maintains compact size.

Example:

• Media Playing Indicator
• Notification Count (1, 2, 3...)

This state does not expose media metadata or notification content.

Represents:

"Something is happening."

Not:

"Here are all the details."

---

3. Media Expanded State

Purpose:
User intentionally expands media controls.

Behavior:

* Shows track information.
* Shows playback controls.
* Allows interaction with currently playing media.

Represents:

"Let me interact with what is currently playing."

This state is only entered intentionally.

---

4. Password Entry State

Purpose:
Primary lockscreen authentication state.

Behavior:

* Island expands.
* Password field appears.
* User authenticates through the island.

Represents:

"Unlock the system."

This is the most important lockscreen interaction state.

---

5. Notification Alert State

Purpose:
Temporary attention state when a new notification arrives.

Behavior:

* Brief expansion or visual alert.
* Shows notification presence only.
* Does not reveal content.

Examples:

"1 New Notification"
"3 New Notifications"

After acknowledgement or timeout, returns to Presence State.

Represents:

"Something new arrived."

Not:

"Here is the message."

---

State Hierarchy

Idle
↓
Presence
↓
Media Expanded

Password Entry

Notification Alert

Notification Alert is temporary.

Password Entry is explicit.

Presence is the normal active state.

Idle is the resting state.

---

Privacy Philosophy

Notifications on the lockscreen should not reveal content.

Allowed:

* Notification count.
* Notification existence.

Not Allowed:

* Message previews.
* Sender names.
* Notification details.

The lockscreen should communicate activity without exposing personal information.

---

Architectural Philosophy

Desktop Island:
Interaction Layer

* Operations
* Bluetooth
* Wi-Fi
* Prompts
* System Events
* Notifications
* Media

Lockscreen Island:
Presence Layer

* Idle
* Presence
* Media
* Authentication
* Notification Awareness

The lockscreen island should remain intentionally simpler than the desktop island.

Complexity belongs after authentication.

---

Key Reflection Principle

The lockscreen island follows Reflection's established design philosophy:

Compact by default.
Expanded only when requested.

The system should communicate only what is necessary and reveal more information only when the user explicitly asks for it.
