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
    property var currentNotif: null
    property int unreadCount: State.GlobalStates.notificationHistory ? State.GlobalStates.notificationHistory.count : 0
    property bool active: false
    property real popProgress: 0
    readonly property bool isHovered: ma.containsMouse

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

    function trigger(notif) {
        if (notif) currentNotif = notif;
        active = true;
        dismissTimer.restart();
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

    // Auto-dismiss after 5 seconds (paused if hovered)
    Timer {
        id: dismissTimer
        interval: 5000
        repeat: false
        running: root.active && !root.isHovered
        onTriggered: root.dismiss()
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

    // Outer Glow / Notification Accent Aura
    RectangularGlow {
        anchors.fill: orbBackground
        glowRadius: 14
        spread: 0.08
        color: root.theme ? root.theme.accentNotification : "#89B4FA"
        cornerRadius: orbBackground.radius + glowRadius
        opacity: Math.max(0, (root.popProgress - 0.2) / 0.8) * (root.isHovered ? 0.65 : 0.40)

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
        border.color: root.theme ? Qt.rgba(root.theme.accentNotification.r, root.theme.accentNotification.g, root.theme.accentNotification.b, 0.6) : Qt.rgba(0.54, 0.71, 0.98, 0.6)

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
                starColor: root.theme ? root.theme.accentNotification : "#89B4FA"
                opacity: 0.35
            }

            // App Icon or Fallback Bell
            Item {
                anchors.centerIn: parent
                width: 22
                height: 22

                Image {
                    id: appIcon
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: source.toString() !== "" && status === Image.Ready
                    source: {
                        if (!root.currentNotif) return "";
                        var img = root.currentNotif.image || "";
                        var icn = root.currentNotif.icon || "";
                        if (img) {
                            if (img.indexOf("://") === -1 && !img.startsWith("/")) return "image://icon/" + img;
                            return img;
                        }
                        if (icn) {
                            if (icn.indexOf("://") === -1 && !icn.startsWith("/")) return "image://icon/" + icn;
                            return icn;
                        }
                        return "";
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: !appIcon.visible
                    text: "notifications"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: root.theme ? root.theme.accentNotification : "#89B4FA"
                }
            }

            // Plain, simple unread count number (no surrounding pill box)
            Text {
                visible: root.unreadCount > 1
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 3
                anchors.rightMargin: 6
                text: root.unreadCount > 9 ? "9+" : root.unreadCount.toString()
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 10
                font.weight: Font.Bold
                color: root.theme ? root.theme.accentNotification : "#89B4FA"
            }
        }

        // Interactive Click Area (Left-click expands, Right-click dismisses)
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    if (root.currentNotif && typeof root.currentNotif.close === "function") {
                        root.currentNotif.close();
                    }
                    root.dismiss();
                } else {
                    root.dismiss();
                    root.expandRequested();
                }
            }
        }
    }
}

