# Reflection UI Color & Focus Philosophy

## Core Principle

Colors should communicate meaning rather than exist solely for decoration.

Reflection should avoid using accent colors simply because they look good.

Each color should have a clear purpose that users can subconsciously learn over time.

---

# Reflection Color Language

## Black

Purpose:

Surface color.

Used for:

* Panels
* Island
* Taskbar
* Control Center
* General UI surfaces

Reasoning:

* OLED-friendly
* Reduces visual noise
* Allows content and interactions to stand out

---

## White

Purpose:

Information.

Used for:

* Text
* Icons
* Labels
* Readability

White communicates information rather than state.

---

## Indigo / Purple

Purpose:

Reflection Identity.

Used for:

* Waveforms
* Workspace indicators
* Notification indicators
* General Reflection branding
* Passive activity indicators

Question Answered:

"What belongs to Reflection?"

Indigo represents the desktop's personality and presence.

---

## Orange / Gold

Purpose:

Focus & Interaction.

Used for:

* Active controls
* Current user interaction
* Elements currently being manipulated
* Potentially enabled quick actions

Question Answered:

"What am I interacting with right now?"

Orange represents user attention.

---

# Focus-Driven UI

Reflection should prioritize highlighting what the user is actively engaged with.

The goal is not to emphasize every available option.

The goal is to emphasize the user's current focus.

---

# Control Center Example

## Idle State

Volume Slider

Brightness Slider

Neutral appearance.

Nothing is currently being adjusted.

---

## Volume Adjustment

User grabs volume slider.

Volume slider transitions to orange.

Brightness remains neutral.

Meaning:

"This is the control currently being manipulated."

---

## Brightness Adjustment

User grabs brightness slider.

Brightness slider transitions to orange.

Volume returns to neutral.

Meaning:

"This is where the user's attention currently is."

---

## Release Behavior

Upon releasing a slider:

Orange should not disappear instantly.

Instead:

Orange
↓
Short fade
↓
Neutral State

Suggested transition:

200–300ms fade.

This helps the interface feel smoother and more premium.

---

# Reflection Focus Philosophy

Reflection should react to user intent.

The UI should not merely display information.

The UI should acknowledge where the user's attention is currently directed.

Examples:

## Dynamic Island

Idle
↓
Expanded

User requested more information.

---

## Taskbar

Hidden
↓
Visible

User requested navigation.

---

## Lockscreen

Clock View
↓
Authentication View

User requested access.

---

## Control Center

Neutral Control
↓
Highlighted Control

User is actively interacting with it.

---

# Design Goal

Reflection should feel aware of user intent.

Instead of emphasizing everything equally, the interface should guide attention toward:

* What is happening
* What the user is changing
* What currently has focus

The desktop should feel responsive and attentive without becoming visually noisy.

---

# Desired Feeling

The user should never wonder:

"Which thing am I changing?"

The UI should answer that question naturally through motion, color, and state changes.

Reflection should highlight attention rather than demand attention.
