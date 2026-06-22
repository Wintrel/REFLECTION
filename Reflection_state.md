# Reflection State – Intent-Based Interaction System

## Core Philosophy

Reflection should not treat the Super key as an application launcher.

Instead, the Super key should open a dedicated Reflection State within the Dynamic Island.

The Dynamic Island currently acts as the place where the system communicates with the user.

Reflection State becomes the place where the user communicates with the system.

### Dynamic Island

System → User

Examples:

* Bluetooth pairing requests
* WiFi authentication
* Progress operations
* Status changes
* Notifications

### Reflection State

User → System

Examples:

* Launch applications
* Execute commands
* Navigate running applications
* Perform calculations
* Access settings
* Control hardware features
* Future AI-assisted actions

---

## Reflection State Workflow

The user presses Super.

The Dynamic Island expands into Reflection State.

The primary prompt becomes:

"What would you like to do?"

The user describes an intent.

Reflection interprets the intent and presents suggested actions.

Reflection should prefer:

Intent → Suggestion → Confirmation → Action

rather than:

Intent → Guess → Immediate Action

This keeps behavior predictable and safe.

---

## Phase 1 – Foundation

### Application Launching

Input:

* firefox
* discord
* steam

Output:

* Launch application

### Running Application Awareness

If an application is already running:

Input:

* discord

Output:

* Discord
* Running on Workspace 3

Action:

* Switch to the existing instance instead of opening a duplicate.

Reflection becomes an orchestrator rather than a launcher.

### Command Actions

Input:

* lock
* sleep
* reboot
* screenshot

Output:

* Matching system actions

### Calculator

Input:

* 25 * 400

Output:

* 10000

---

## Phase 2 – Context Awareness

Reflection begins using information already available in the shell.

Known Context:

* Running applications
* Active workspaces
* Bluetooth devices
* Media playback
* Audio devices
* Battery state
* Power profile
* Time of day

Examples:

Input:

* connect my earbuds

Output:

* Connect Galaxy Buds 3 Pro?

Input:

* where is discord

Output:

* Discord is running on Workspace 5
* Switch to Workspace 5?

Input:

* continue coding

Output:

* VSCode
* Terminal
* Browser
* Open development workspace?

The system begins understanding intent through context.

---

## Phase 3 – Hardware Awareness

Future integrations:

* ASUSD
* supergfxctl
* power-profiles-daemon
* Battery management services

Examples:

Input:

* make laptop quieter

Output:

* Suggested Action:
* Balanced → Silent Profile

Input:

* battery life

Output:

* Current battery
* Estimated runtime
* Suggested power profile

---

## Phase 4 – Reflection Intelligence Layer

Reflection gains lightweight AI-assisted interpretation.

Goal:

NOT:
"AI Assistant"

Goal:
"Intent Understanding"

Examples:

Input:

* discrod

Output:

* Did you mean Discord?

Input:

* bluetooh

Output:

* Did you mean Bluetooth?

Input:

* connect my headphones

Output:

* Reflection identifies likely Bluetooth devices and suggests the correct action.

The AI layer should improve interpretation and reduce friction rather than replace existing systems.

---

## Long-Term Vision

Most desktop environments have a launcher.

Reflection should have an Intent Surface.

The Dynamic Island becomes a two-way communication system:

System → User
(Dynamic Island States)

User → System
(Reflection State)

The launcher ultimately evolves into the place where Reflection listens.
