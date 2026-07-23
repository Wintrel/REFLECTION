import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../core" as Core
import "../../../core/state" as State
import "../../../core/services/system"
import "../../../core/monitors"

Scope {
    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            id: edgeWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region { item: Item {} } // Pass all clicks through to desktop
            color: "transparent"

            Core.Theme { id: theme }

            property bool isActive: false
            property color currentColor: theme.accentNotification
            
            Connections {
                target: State.GlobalStates
                function onNotificationTriggered() {
                    if (edgeWindow.isPromptActive) return;
                    edgeWindow.currentColor = theme.accentPrimary;
                    edgeWindow.isActive = true;
                    hideTimer.restart();
                }
            }

            property bool isPromptActive: false

            Connections {
                target: PromptService
                function onPromptRequested() {
                    edgeWindow.isPromptActive = true;
                    edgeWindow.currentColor = theme.accentPrimary;
                    edgeWindow.isActive = true;
                    hideTimer.stop();
                }
                function onCanceled() {
                    edgeWindow.isPromptActive = false;
                    edgeWindow.isActive = false;
                }
                function onSubmitted() {
                    edgeWindow.isPromptActive = false;
                    edgeWindow.isActive = false;
                }
            }

            Connections {
                target: PolkitAuthService
                function onPolkitRequestStarted() {
                    edgeWindow.isPromptActive = true;
                    edgeWindow.currentColor = "#ff4444"; // Aggressive red for Polkit.
                    edgeWindow.isActive = true;
                    hideTimer.stop();
                }
                function onPolkitRequestFinished() {
                    edgeWindow.isPromptActive = false;
                    edgeWindow.isActive = false;
                }
            }

            Timer {
                id: hideTimer
                interval: 5000 // 5 seconds of edge glow.
                onTriggered: {
                    if (!edgeWindow.isPromptActive) {
                        edgeWindow.isActive = false;
                    }
                }
            }

            // ── Samsung Edge Lighting ──
            // Thin gradient lines that travel along the screen border.
            // No orbs, no RadialGradient blobs — just slim rectangles.

            property real perimeter: 2 * (width + height)
            property real travelProgress: 0
            property real trailWidth: 550 // Length of the visible light trail (px)

            NumberAnimation {
                target: edgeWindow
                property: "travelProgress"
                from: 0; to: 1
                duration: 4200
                loops: Animation.Infinite
                running: edgeWindow.isActive
            }

            // Convert normalized perimeter position (0–1) to screen X,Y
            function perimeterToXY(t) {
                if (perimeter <= 0) return { x: 0, y: 0 };
                var p = ((t % 1) + 1) % 1;
                var d = p * perimeter;
                var w = width, h = height;
                if (d < w)     return { x: d,     y: 0 };
                d -= w;
                if (d < h)     return { x: w,     y: d };
                d -= h;
                if (d < w)     return { x: w - d, y: h };
                d -= w;
                return           { x: 0,     y: h - d };
            }

            // Two light streams, offset by half the perimeter
            property var s1: perimeterToXY(travelProgress)
            property var s2: perimeterToXY(travelProgress + 0.5)

            // ── Light Trail Component ──
            // A slim traveling light: 2px bright line at the screen edge
            // + layered bloom fading inward (total ~10px visible depth).
            // Uses Rectangle with Gradient — no heavy effects.
            component LightTrail: Item {
                id: lt
                property real headPos: 0      // x for horizontal edges, y for vertical
                property bool horiz: true      // horizontal (top/bottom) vs vertical (left/right)
                property bool atStart: true    // edge is at start side (top or left)

                property color c: edgeWindow.currentColor
                property real intensity: theme.edgeLightingIntensity

                // ─ Main bright line (2px) ─
                Rectangle {
                    width:  lt.horiz ? edgeWindow.trailWidth : 2
                    height: lt.horiz ? 2 : edgeWindow.trailWidth
                    x: lt.horiz
                        ? lt.headPos - width / 2
                        : (lt.atStart ? 0 : lt.width - 2)
                    y: lt.horiz
                        ? (lt.atStart ? 0 : lt.height - 2)
                        : lt.headPos - height / 2
                    gradient: Gradient {
                        orientation: lt.horiz ? Gradient.Horizontal : Gradient.Vertical
                        GradientStop { position: 0.0;  color: "transparent" }
                        GradientStop { position: 0.20; color: Qt.rgba(lt.c.r, lt.c.g, lt.c.b, lt.intensity * 0.15) }
                        GradientStop { position: 0.45; color: Qt.rgba(lt.c.r, lt.c.g, lt.c.b, lt.intensity * 0.85) }
                        GradientStop { position: 0.50; color: Qt.rgba(lt.c.r, lt.c.g, lt.c.b, lt.intensity) }
                        GradientStop { position: 0.55; color: Qt.rgba(lt.c.r, lt.c.g, lt.c.b, lt.intensity * 0.85) }
                        GradientStop { position: 0.80; color: Qt.rgba(lt.c.r, lt.c.g, lt.c.b, lt.intensity * 0.15) }
                        GradientStop { position: 1.0;  color: "transparent" }
                    }
                }

                // ─ Bloom layer 1: soft inner glow (4px, offset 2px from edge) ─
                Rectangle {
                    width:  lt.horiz ? edgeWindow.trailWidth * 0.7 : 4
                    height: lt.horiz ? 4 : edgeWindow.trailWidth * 0.7
                    x: lt.horiz
                        ? lt.headPos - width / 2
                        : (lt.atStart ? 2 : lt.width - 6)
                    y: lt.horiz
                        ? (lt.atStart ? 2 : lt.height - 6)
                        : lt.headPos - height / 2
                    gradient: Gradient {
                        orientation: lt.horiz ? Gradient.Horizontal : Gradient.Vertical
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(lt.c.r, lt.c.g, lt.c.b, lt.intensity * 0.12) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // ─ Bloom layer 2: faint outer halo (3px, offset 6px from edge) ─
                Rectangle {
                    width:  lt.horiz ? edgeWindow.trailWidth * 0.45 : 3
                    height: lt.horiz ? 3 : edgeWindow.trailWidth * 0.45
                    x: lt.horiz
                        ? lt.headPos - width / 2
                        : (lt.atStart ? 6 : lt.width - 9)
                    y: lt.horiz
                        ? (lt.atStart ? 6 : lt.height - 9)
                        : lt.headPos - height / 2
                    gradient: Gradient {
                        orientation: lt.horiz ? Gradient.Horizontal : Gradient.Vertical
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(lt.c.r, lt.c.g, lt.c.b, lt.intensity * 0.04) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            // ── Visual container ──
            Item {
                id: visualContainer
                anchors.fill: parent
                opacity: edgeWindow.isActive ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation { duration: 800; easing.type: Easing.InOutSine }
                }

                // ─ Top edge ─
                Item {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 12; clip: true
                    LightTrail { anchors.fill: parent; horiz: true;  atStart: true;  headPos: edgeWindow.s1.x }
                    LightTrail { anchors.fill: parent; horiz: true;  atStart: true;  headPos: edgeWindow.s2.x }
                }

                // ─ Bottom edge ─
                Item {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 12; clip: true
                    LightTrail { anchors.fill: parent; horiz: true;  atStart: false; headPos: edgeWindow.s1.x }
                    LightTrail { anchors.fill: parent; horiz: true;  atStart: false; headPos: edgeWindow.s2.x }
                }

                // ─ Left edge ─
                Item {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: 12; clip: true
                    LightTrail { anchors.fill: parent; horiz: false; atStart: true;  headPos: edgeWindow.s1.y }
                    LightTrail { anchors.fill: parent; horiz: false; atStart: true;  headPos: edgeWindow.s2.y }
                }

                // ─ Right edge ─
                Item {
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    width: 12; clip: true
                    LightTrail { anchors.fill: parent; horiz: false; atStart: false; headPos: edgeWindow.s1.y }
                    LightTrail { anchors.fill: parent; horiz: false; atStart: false; headPos: edgeWindow.s2.y }
                }
            }
        }
    }
}
