# Reflection Taskbar – Navigation Layer

## Purpose

The Reflection Taskbar serves as the primary navigation layer of the desktop.

Unlike the Dynamic Island, which communicates system activity and temporary information, the taskbar exists to answer navigation-related questions.

The taskbar should remain simple, focused, and avoid becoming a second information center.

---

# Core Philosophy

Reflection separates system communication from system navigation.

### Dynamic Island

Answers:

"What is happening?"

Examples:

* Notifications
* Music activity
* Volume OSD
* Brightness OSD
* Battery alerts
* Bluetooth and Wi-Fi status

The island is responsible for temporary and contextual information.

---

### Taskbar

Answers:

"Where am I?"

"What is open?"

"What time is it?"

The taskbar is responsible for navigation and orientation.

---

# Layout Structure

The taskbar is divided into three sections.

## Left Side

### Workspace Awareness

Question Answered:

"Where am I?"

Purpose:

Provide awareness of the current workspace and allow rapid navigation between workspaces.

Possible Indicators:

* Active workspace
* Occupied workspaces
* Empty workspaces

Visual Example:

● ○ ● ○ ○

Behavior:

* Clicking switches workspace.
* Active workspace is clearly highlighted.
* Occupied workspaces remain visible.
* Empty workspaces are subdued.

This section is specifically designed around Hyprland's workflow and workspace-centric navigation.

---

## Center

### Application Navigation

Question Answered:

"What is open?"

Purpose:

Display currently running applications and provide a quick way to locate them.

Behavior:

* Show application icons only.
* Clicking an application focuses it.
* If the application exists on another workspace, automatically switch to that workspace.
* Multiple windows may use indicators or grouping if needed.

This section acts as a desktop-wide navigation map.

The goal is not simply to launch applications but to locate them.

---

## Right Side

### Time Awareness

Question Answered:

"What time is it?"

Purpose:

Provide lightweight temporal awareness.

Contents:

* Current time
* Optional date

Examples:

22:47

or

22:47
19 Jun

This section intentionally remains minimal.

---

# Information Hierarchy

The taskbar should never duplicate information already handled by the Dynamic Island.

Avoid:

* Notifications
* Music controls
* Volume controls
* Battery indicators
* Bluetooth indicators
* Wi-Fi indicators

These responsibilities belong to the island.

---

# Relationship to the Dynamic Island

Reflection follows a top-and-bottom structure.

### Top Layer

Dynamic Island

Question:

"What is happening?"

Handles:

* System activity
* Notifications
* OSDs
* Temporary information

---

### Bottom Layer

Taskbar

Questions:

"Where am I?"

"What is open?"

"What time is it?"

Handles:

* Workspace navigation
* Application navigation
* Time awareness

---

# Reflection Layout Philosophy

Top:
System Activity

Center:
User Content

Bottom:
System Navigation

The desktop itself remains the primary focus.

The island informs.

The taskbar navigates.

Neither should compete for attention.

---

# Reflection v1 Taskbar Goal

Left:
Workspace Indicators

Center:
Running Applications

Right:
Time and Date

The first version should focus on clarity, navigation, and consistency before additional functionality is considered.
