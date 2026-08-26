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
    property var rightNeighbor: null
    property bool active: false
    property real popProgress: 0
    readonly property bool isHovered: ma.containsMouse

    readonly property bool inProgress: ActionProgressService.inProgress
    readonly property bool isResolving: ActionProgressService.isResolving
    readonly property bool isSuccess: ActionProgressService.isSuccess

    signal expandRequested()

    width: theme ? theme.islandMinH : 45
    height: theme ? theme.islandMinH : 45

    // Right-emergence geometry: accommodates right neighbor if active (e.g. BatteryOrb)
    readonly property real baseRightX: {
        if (!targetWidget) return 0;
        if (rightNeighbor && rightNeighbor.active && rightNeighbor.popProgress > 0.5) {
            return targetWidget.x + targetWidget.width + rightNeighbor.width + 10;
        }
        return targetWidget.x + targetWidget.width;
    }

    x: targetWidget ? (baseRightX - (width + 6) + (popProgress * (width + 16))) : 0
    y: targetWidget ? (targetWidget.y + (targetWidget.height - height) / 2) : 0

    opacity: Math.min(1.0, popProgress * 1.4)
    visible: popProgress > 0

    readonly property color activeColor: {
        if (root.isResolving) {
            return root.isSuccess ? "#79D6A1" : "#FF5555";
        }
        return root.theme ? root.theme.accentPrimary : "#00F5FF";
    }

    function trigger() {
        active = true;
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

    // Auto-dismiss 2.2s after task completes / resolves
    Timer {
        id: resolveTimer
        interval: 2200
        repeat: false
        onTriggered: {
            if (!root.inProgress) {
                root.dismiss();
            }
        }
    }

    onIsResolvingChanged: {
        if (isResolving) {
            resolveTimer.restart();
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

    // Outer Glow / Progress Aura
    RectangularGlow {
        anchors.fill: orbBackground
        glowRadius: root.isResolving ? 18 : 14
        spread: 0.08
        color: root.activeColor
        cornerRadius: orbBackground.radius + glowRadius
        opacity: Math.max(0, (root.popProgress - 0.2) / 0.8) * (root.isHovered ? 0.65 : 0.45)

        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on color { ColorAnimation { duration: 300 } }
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

            // Spinning Progress Ring Arc (while in progress)
            Canvas {
                id: progressRing
                anchors.fill: parent
                anchors.margins: 4
                visible: root.inProgress && !root.isResolving

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);

                    var cx = width / 2;
                    var cy = height / 2;
                    var radius = (width / 2) - 2;

                    ctx.lineWidth = 2.5;
                    ctx.lineCap = "round";
                    ctx.strokeStyle = root.activeColor.toString();

                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, 0, 1.5 * Math.PI, false);
                    ctx.stroke();
                }

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    running: root.inProgress && !root.isResolving && root.active
                    from: 0
                    to: 360
                    duration: 1100
                }
            }

            // Completed Ring Outline (on success / resolve)
            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: root.activeColor
                visible: root.isResolving
                opacity: root.isResolving ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // Dynamic Action / Resolution Icon
            Text {
                id: actionIcon
                anchors.centerIn: parent
                text: {
                    if (root.isResolving) {
                        return root.isSuccess ? "check" : "close";
                    }
                    return ActionProgressService.statusIcon || "progress_activity";
                }
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: root.activeColor
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }

        // Interactive Click Area (Expands full action card)
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.dismiss();
                root.expandRequested();
            }
        }
    }
}

