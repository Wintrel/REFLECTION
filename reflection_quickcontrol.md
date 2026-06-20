# Reflection Control Center – Quick Control Layer

## Purpose

The Reflection Control Center serves as the system's quick control layer.

Unlike the Dynamic Island, which reflects system activity, and the Taskbar, which provides navigation, the Control Center exists to provide immediate access to commonly adjusted settings.

Question Answered:

"What can I change right now?"

---

# Reflection UI Architecture

## Dynamic Island

Purpose:

Reflect system activity.

Question:

"What is happening?"

Handles:

* Notifications
* Music activity
* OSDs
* System events

---

## Taskbar

Purpose:

Navigation.

Questions:

"Where am I?"

"What is open?"

"What time is it?"

Handles:

* Workspaces
* Running applications
* Date and time

---

## Control Center

Purpose:

Quick control.

Question:

"What can I change right now?"

Handles:

* Volume
* Brightness
* WiFi
* Bluetooth
* DND
* Night Light
* Power Actions
* Settings Access

---

# Location

The Control Center should be anchored to the bottom-right corner of the desktop.

Reasoning:

* Top space is already occupied by the Dynamic Island.
* Prevents competition between major Reflection components.
* Maintains clear visual hierarchy.
* Familiar interaction pattern for users.

Suggested Trigger:

Clicking the date/time area of the taskbar.

---

# Design Philosophy

The Control Center should not become a miniature settings application.

It exists for immediate actions and frequently adjusted controls.

Reflection prioritizes:

Quick access.

Low visual clutter.

Intent-driven interaction.

---

# Layout Structure

## Frequent Controls

These controls should receive the most visual emphasis because they are adjusted most often.

### Volume

Large slider.

### Brightness

Large slider.

Reasoning:

These are daily-use controls and represent the primary purpose of a quick settings panel.

---

## Toggle Controls

Secondary controls.

Examples:

* WiFi
* Bluetooth
* DND
* Night Light

These should be accessible but visually secondary to volume and brightness.

---

## System Actions

Located at the bottom of the panel.

Examples:

* Power
* Lock
* Settings

These are less frequently used and should not dominate the interface.

---

# Suggested Layout

╭─────────────────╮
│ Volume          │
│ ▓▓▓▓▓▓▓▓▓▓▓     │
│                 │
│ Brightness      │
│ ▓▓▓▓▓▓▓▓▓       │
│                 │
│ WiFi      ON    │
│ Bluetooth ON    │
│ DND       OFF   │
│ Night Light OFF │
│                 │
│ Power      →    │
│ Settings   →    │
╰─────────────────╯

---

# Relationship to OSDs

Volume and brightness already have dedicated OSDs.

OSDs answer:

"What just changed?"

The Control Center answers:

"What do I want to change?"

These systems complement one another and should not replace each other.

---

# Relationship to Reflection Design

The Control Center should follow the same visual language as the rest of Reflection.

Shared Characteristics:

* Floating appearance
* Rounded corners
* Black OLED-friendly surfaces
* Indigo accent color
* Smooth animations
* Consistent spacing

The panel should feel like another Reflection component rather than a separate application.

---

# Desired Feeling

The Control Center should feel lightweight, approachable, and intentional.

It should provide immediate access to common controls without overwhelming the user with information.

Reflection components should have distinct responsibilities:

Island → Reflect

Taskbar → Navigate

Control Center → Modify

Together they form the core Reflection desktop shell.
