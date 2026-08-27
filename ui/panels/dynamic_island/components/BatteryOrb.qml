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
    property bool manualActive: false
    readonly property bool active: BatteryService.isOneshotCharging || manualActive
    property real popProgress: 0
    readonly property bool isHovered: ma.containsMouse

    signal expandRequested()

    width: BatteryService.isOneshotCharging ? 94 : 78
    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
    height: theme ? theme.islandMinH : 45

    // Physical emergence geometry:
    // When popProgress = 0, sits tucked completely inside/behind the island's right bezel.
    // When popProgress = 1, emerges fully into view +10px to the right of the island.
    x: targetWidget ? (targetWidget.x + targetWidget.width - (width + 6) + (popProgress * (width + 16))) : 0
    y: targetWidget ? (targetWidget.y + (targetWidget.height - height) / 2) : 0

    opacity: Math.min(1.0, popProgress * 1.4)
    visible: popProgress > 0

    function trigger() {
        manualActive = true;
        dismissTimer.restart();
    }

    function dismiss() {
        manualActive = false;
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

    // Auto-dismiss after 4.5 seconds (paused if cursor is hovering or One-Shot is active)
    Timer {
        id: dismissTimer
        interval: 4500
        repeat: false
        running: root.active && !BatteryService.isOneshotCharging && !root.isHovered
        onTriggered: root.dismiss()
    }

    // Ejection Pop-out Animation with droplet momentum & spring settle
    ParallelAnimation {
        id: popAnim
        
        // Horizontal slide out
        NumberAnimation {
            target: root
            property: "popProgress"
            from: 0.0
            to: 1.0
            duration: root.theme ? root.theme.durationMorph : 360
            easing.type: root.theme ? root.theme.easingMorph : Easing.OutBack
            easing.overshoot: root.theme ? root.theme.morphOvershoot : 0.35
        }

        // Droplet stretch X (stretches as it emerges, springs back on detach)
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

        // Droplet compress Y (fluid volume preservation)
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

    // Ingest & Absorption Retract Animation
    ParallelAnimation {
        id: retractAnim
        
        // Slide back inside the island
        NumberAnimation {
            target: root
            property: "popProgress"
            to: 0.0
            duration: 260
            easing.type: Easing.InCubic
        }

        // Stretch toward the island as it gets pulled in
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

    // // Outer Glow / Charging Aura (ignites as the orb detaches)
    // RectangularGlow {
    //     anchors.fill: orbBackground
    //     glowRadius: BatteryService.isOneshotCharging ? 18 : 14
    //     spread: BatteryService.isOneshotCharging ? 0.12 : 0.08
    //     color: BatteryService.isOneshotCharging 
    //            ? "#FFB800" 
    //            : (BatteryService.isCharging 
    //               ? "#79D6A1" 
    //               : (BatteryService.percentage <= 20 ? "#FF5555" : (root.theme ? root.theme.accentPrimary : "#00FFCC")))
    //     cornerRadius: orbBackground.radius + glowRadius
    //     opacity: Math.max(0, (root.popProgress - 0.2) / 0.8) * (root.isHovered ? 0.65 : (BatteryService.isOneshotCharging ? 0.55 : 0.40))
        
    //     Behavior on opacity { NumberAnimation { duration: 180 } }
    //     Behavior on color { ColorAnimation { duration: 300 } }
    // }

    // Orb Pill Container
    Rectangle {
        id: orbBackground
        anchors.fill: parent
        radius: height / 2
        color: root.theme ? root.theme.bgBezel : "#000000"

        transform: Scale {
            id: dropletScale
            origin.x: 0 // anchored to left edge as it ejects rightward
            origin.y: orbBackground.height / 2
            xScale: 1.0
            yScale: 1.0
        }

        border.width: root.theme && root.theme.islandBorderWidth > 0 ? 1 : 0
        border.color: BatteryService.isOneshotCharging
                      ? Qt.rgba(1.0, 0.72, 0.0, 0.8)
                      : (BatteryService.isCharging 
                         ? Qt.rgba(0.47, 0.84, 0.63, 0.65)
                         : (BatteryService.percentage <= 20 
                            ? Qt.rgba(1.0, 0.33, 0.33, 0.65) 
                            : (root.theme ? Qt.rgba(root.theme.colorSystemShimmer.r, root.theme.colorSystemShimmer.g, root.theme.colorSystemShimmer.b, 0.4) : "transparent")))

        // Subtle press & hover scale
        scale: ma.pressed ? 0.95 : (root.isHovered ? 1.04 : 1.0)
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
                starColor: BatteryService.isOneshotCharging ? "#FFB800" : (BatteryService.isCharging ? "#79D6A1" : (root.theme ? root.theme.textMain : "#FFF"))
                opacity: 0.35
            }

            // Orb Content Layout: Bolt/Battery Icon + Percentage + 1x Badge
            Row {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    id: batteryIcon
                    text: BatteryService.isOneshotCharging 
                          ? "bolt" 
                          : (BatteryService.isCharging ? "electric_bolt" : (BatteryService.percentage <= 20 ? "battery_alert" : "battery_full"))
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 17
                    color: BatteryService.isOneshotCharging 
                           ? "#FFB800" 
                           : (BatteryService.isCharging 
                              ? "#79D6A1" 
                              : (BatteryService.percentage <= 20 ? "#FF5555" : (root.theme ? root.theme.textMain : "#FFF")))
                    anchors.verticalCenter: parent.verticalCenter

                    // Charging pulse animation on the bolt icon
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: (BatteryService.isCharging || BatteryService.isOneshotCharging) && root.active
                        NumberAnimation { from: 1.0; to: 0.4; duration: 600; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.4; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                    }
                }

                Text {
                    id: batteryPercent
                    text: BatteryService.percentage + "%"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: BatteryService.isOneshotCharging 
                           ? "#FFB800" 
                           : (BatteryService.isCharging 
                              ? "#79D6A1" 
                              : (BatteryService.percentage <= 20 ? "#FF5555" : (root.theme ? root.theme.textMain : "#FFF")))
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Interactive Click & Hold Area (Click opens Battery Card, Hold toggles One-Shot)
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            pressAndHoldInterval: 750

            onPressAndHold: {
                if (BatteryService.isOneshotCharging) {
                    BatteryService.cancelOneshot();
                } else {
                    BatteryService.chargeFullOnce();
                }
            }

            onClicked: {
                if (!BatteryService.isOneshotCharging) {
                    root.dismiss();
                }
                root.expandRequested();
            }
        }
    }
}

