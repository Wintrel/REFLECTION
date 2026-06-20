# Reflection Lockscreen – Context-Aware Authentication

## Purpose

The Reflection Lockscreen is designed around the idea that a locked system and an unlocking system are two different states.

Rather than displaying authentication elements at all times, the lockscreen adapts based on user intent.

The goal is to create a calm, welcoming experience that transitions naturally into authentication when required.

---

# Core Philosophy

The lockscreen should not immediately present the user with a password field.

When the system is locked, the user is typically:

* Checking the time
* Viewing notifications
* Returning to the device

Authentication should only appear once the user indicates intent to unlock the system.

---

# State 1 – Passive Lock State

Question Answered:

"What is happening while the system is locked?"

### Contents

* Current time
* Current date
* Wallpaper
* Privacy-safe notifications
* Dynamic Island (lockscreen mode)

### Layout

The lockscreen remains clean and unobtrusive.

Primary focus:

```text
01:45

20 June
```

Authentication controls remain hidden.

---

# Lockscreen Dynamic Island

The island remains active while locked.

Its role changes from interaction to awareness.

### Allowed

* Notification source
* Application icon
* Notification count

### Not Allowed

* Message contents
* Email contents
* Private notification details

Example:

Discord
New Notification

Instead of:

Discord
"Hey, are you coming online tonight?"

The lockscreen should preserve privacy while still reflecting system activity.

---

# State 2 – Authentication State

Triggered by:

* Mouse click
* Key press
* Touchpad interaction
* Any deliberate unlock attempt

Question Answered:

"Who is unlocking the system?"

### Transition

Clock fades away.

Authentication interface fades in.

The transition should feel smooth and intentional rather than abrupt.

---

# Authentication View

### Contents

* User avatar
* Username
* Password field

Visual inspiration:

Windows 11 user authentication screen.

Example:

```text
      [Avatar]

      Wintrel

   Password Field
```

The avatar becomes the focal point of the screen.

---

# State Flow

Locked
↓
Clock View

User Interaction
↓
Authentication View

Successful Login
↓
Reflection Desktop

---

# Design Principles

* Calm before authentication.
* Authentication appears only when requested.
* Smooth transitions between states.
* Privacy-first notification behavior.
* Consistent with Reflection's state-driven design language.

---

# Relationship to Reflection

The lockscreen follows the same philosophy as the rest of Reflection.

### Dynamic Island

Idle
↓
Expanded

### Taskbar

Hidden
↓
Visible

### Lockscreen

Clock View
↓
Authentication View

Reflection components should reveal complexity only when the user requests it.

---

# Desired Feeling

The lockscreen should feel welcoming rather than transactional.

The user should experience:

1. Awareness (time and notifications)
2. Intent (interaction)
3. Authentication
4. Entry into the desktop

The transition should feel like moving deeper into the system rather than immediately encountering a login prompt.

---

# Reflection v1 Lockscreen Goals

* Large centered clock
* Date display
* Lockscreen-aware Dynamic Island
* Privacy-safe notifications
* Smooth transition to authentication state
* Centered avatar and password field
* Consistent Reflection styling
* OLED-friendly presentation
