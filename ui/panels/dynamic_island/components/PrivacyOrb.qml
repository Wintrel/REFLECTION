import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/state" as State
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root

    property var theme: null
    property var targetWidget: null
    property var batteryNeighbor: null
    property var progressNeighbor: null

    readonly property bool active: PrivacyService.isPrivacyActive
    property real popProgress: 0
    readonly property bool isHovered: ma.containsMouse

    readonly property color activeColor: PrivacyService.primaryColor
    readonly property string activeIcon: PrivacyService.primaryIcon

    signal expandRequested()

    width: theme ? theme.islandMinH : 45
    height: theme ? theme.islandMinH : 45

    // Right-emergence geometry: stacks dynamically with battery and progress neighbors
    readonly property real baseRightX: {
        if (!targetWidget) return 0;
        var offset = targetWidget.x + targetWidget.width;
        if (batteryNeighbor && batteryNeighbor.active && batteryNeighbor.popProgress > 0.5) {
            offset += batteryNeighbor.width + 10;
        }
        if (progressNeighbor && progressNeighbor.active && progressNeighbor.popProgress > 0.5) {
            offset += progressNeighbor.width + 10;
        }
        return offset;
    }

    x: targetWidget ? (baseRightX - (width + 6) + (popProgress * (width + 16))) : 0
    y: targetWidget ? (targetWidget.y + (targetWidget.height - height) / 2) : 0

    opacity: Math.min(1.0, popProgress * 1.4)
    visible: popProgress > 0

    onActiveChanged: {
        if (active) {
            retractAnim.stop();
            popAnim.restart();
        } else {
            popAnim.stop();
            retractAnim.restart();
        }
    }

    // Ejection Pop-out Animation to the right with droplet momentum
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

    // Ingest & Absorption Retract Animation back to the island
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

    // Orb Circular Container
    Rectangle {
        id: orbBackground
        anchors.fill: parent
        radius: height / 2
        color: root.theme ? root.theme.bgBezel : "#000000"

        transform: Scale {
            id: dropletScale
            origin.x: 0
            origin.y: orbBackground.height / 2
            xScale: 1.0
            yScale: 1.0
        }

        border.width: root.theme && root.theme.islandBorderWidth > 0 ? 1 : 0
        border.color: Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.65)
        Behavior on border.color { ColorAnimation { duration: 250 } }

        scale: ma.pressed ? 0.95 : (root.isHovered ? 1.05 : 1.0)
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
                starCount: 5
                starColor: root.activeColor
                opacity: 0.35
            }

            // Clean Static Sensor Glyph
            Text {
                id: sensorIcon
                anchors.centerIn: parent
                text: root.activeIcon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 19
                color: root.activeColor
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }

        // Interactive Click Area (Single tap toggles mic mute, Right-click expands audio card)
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.expandRequested();
                } else {
                    PrivacyService.toggleMicMute();
                }
            }
        }
    }
}

