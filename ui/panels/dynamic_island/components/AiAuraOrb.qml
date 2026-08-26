import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/state" as State
import "../../../../core/services/ai"
import "../../../components" as Components

Item {
    id: root

    property var theme: null
    property var targetWidget: null
    property var leftNeighbor: null
    property bool active: false
    property real popProgress: 0
    readonly property bool isHovered: ma.containsMouse

    readonly property bool isGenerating: AiDaemonService.isGenerating

    width: theme ? theme.islandMinH : 45
    height: theme ? theme.islandMinH : 45

    // Left-emergence geometry: accommodates left neighbor if active (e.g. MediaOrb)
    readonly property real baseLeftX: {
        if (!targetWidget) return 0;
        if (leftNeighbor && leftNeighbor.active && leftNeighbor.popProgress > 0.5) {
            return targetWidget.x - leftNeighbor.width - 10;
        }
        return targetWidget.x;
    }

    x: targetWidget ? (baseLeftX + 6 - (popProgress * (width + 16))) : 0
    y: targetWidget ? (targetWidget.y + (targetWidget.height - height) / 2) : 0

    opacity: Math.min(1.0, popProgress * 1.4)
    visible: popProgress > 0

    function trigger() {
        active = true;
        if (!isGenerating) {
            dismissTimer.restart();
        }
    }

    function dismiss() {
        active = false;
    }

    onActiveChanged: {
        if (active) {
            retractAnim.stop();
            popAnim.restart();
        } else {
            popAnim.stop();
            retractAnim.restart();
        }
    }

    // Auto-dismiss 3.5s after generation finishes (paused if cursor is hovering or actively generating)
    Timer {
        id: dismissTimer
        interval: 3500
        repeat: false
        running: root.active && !root.isGenerating && !root.isHovered
        onTriggered: root.dismiss()
    }

    // Ejection Pop-out Animation to the left with droplet momentum
    ParallelAnimation {
        id: popAnim

        NumberAnimation {
            target: root
            property: "popProgress"
            from: 0.0
            to: 1.0
            duration: root.theme ? root.theme.durationMorph : 360
            easing.type: root.theme ? root.theme.easingMorph : Easing.OutBack
            easing.overshoot: root.theme ? root.theme.morphOvershoot : 0.35
        }

        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                from: 0.75
                to: 1.18
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                to: 1.0
                duration: 210
                easing.type: Easing.OutBack
                easing.overshoot: 0.4
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                from: 0.85
                to: 0.90
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                to: 1.0
                duration: 210
                easing.type: Easing.OutBack
                easing.overshoot: 0.4
            }
        }
    }

    // Ingest & Absorption Retract Animation back to the island.
    ParallelAnimation {
        id: retractAnim

        NumberAnimation {
            target: root
            property: "popProgress"
            to: 0.0
            duration: 260
            easing.type: Easing.InCubic
        }

        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                to: 1.14
                duration: 120
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                to: 0.70
                duration: 140
                easing.type: Easing.InQuad
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                to: 0.88
                duration: 120
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                to: 0.75
                duration: 140
                easing.type: Easing.InQuad
            }
        }
    }

    // Outer Cosmic Glow / AI Aura
    RectangularGlow {
        id: aiGlow
        anchors.fill: orbBackground
        glowRadius: root.isGenerating ? 18 : 14
        spread: root.isGenerating ? 0.12 : 0.08
        color: "#00F5FF"
        cornerRadius: orbBackground.radius + glowRadius
        opacity: Math.max(0, (root.popProgress - 0.2) / 0.8) * (root.isHovered ? 0.75 : (root.isGenerating ? 0.60 : 0.40))

        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on glowRadius { NumberAnimation { duration: 300 } }

        // Continuous Cosmic Color Cycling (Cyan <-> Violet)
        SequentialAnimation on color {
            loops: Animation.Infinite
            running: root.active
            ColorAnimation { from: "#00F5FF"; to: "#BD00FF"; duration: 2000; easing.type: Easing.InOutSine }
            ColorAnimation { from: "#BD00FF"; to: "#00F5FF"; duration: 2000; easing.type: Easing.InOutSine }
        }
    }

    // Orb Circular Container
    Rectangle {
        id: orbBackground
        anchors.fill: parent
        radius: height / 2
        color: root.theme ? root.theme.bgBezel : "#000000"

        transform: Scale {
            id: dropletScale
            origin.x: orbBackground.width
            origin.y: orbBackground.height / 2
            xScale: 1.0
            yScale: 1.0
        }

        border.width: root.theme && root.theme.islandBorderWidth > 0 ? 1 : 0
        border.color: aiGlow.color

        scale: ma.pressed ? 0.95 : (root.isHovered ? 1.06 : 1.0)
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

        // Inner Void Glass Inset
        Rectangle {
            anchors.fill: parent
            anchors.margins: root.theme ? root.theme.islandBorderWidth : 1
            radius: Math.max(0, parent.radius - 1)
            color: root.theme ? root.theme.bgInner : "#0A0A0E"
            clip: true

            // Mini Starfield
            Components.Starfield {
                anchors.fill: parent
                starCount: 6
                starColor: aiGlow.color
                opacity: root.isGenerating ? 0.65 : 0.35
            }

            // Cosmic AI Sparkle Glyph (Static Icon with Dynamic Color)
            Text {
                id: sparkleIcon
                anchors.centerIn: parent
                text: "auto_awesome"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: aiGlow.color
            }
        }

        // Interactive Click Area (Toggles Assistant Workspace)
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                State.GlobalStates.toggleAssistantWorkspace();
            }
        }
    }
}

