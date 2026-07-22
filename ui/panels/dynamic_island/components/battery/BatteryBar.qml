import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

Item {
    id: batteryBarContainer
    property Item rootItem

    height: 14

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            SequentialAnimation {
                PauseAnimation { duration: 40 }
                NumberAnimation { duration: rootItem.motionSlow; easing.type: Easing.OutExpo }
            }
        }
    }
    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: 40 }
            NumberAnimation { duration: rootItem.motionMedium }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        radius: 0.5
        color: rootItem.hairline
    }

    RectangularGlow {
        anchors.fill: barFill
        visible: rootItem.panelOpen && barFill.width > 0
        glowRadius: 6
        spread: 0.05
        opacity: BatteryService.isCharging ? 0.72 : 0.46
        color: Qt.rgba(rootItem.barColor.r, rootItem.barColor.g, rootItem.barColor.b, 0.45)
        cornerRadius: barFill.radius + glowRadius
    }

    Rectangle {
        id: barFill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * (rootItem.percentage / 100.0)
        height: 3
        radius: height / 2
        clip: true

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Qt.rgba(rootItem.barColor.r, rootItem.barColor.g, rootItem.barColor.b, 0.42)
            }
            GradientStop {
                position: 0.72
                color: Qt.rgba(rootItem.barColor.r, rootItem.barColor.g, rootItem.barColor.b, 0.86)
            }
            GradientStop { position: 1.0; color: rootItem.barColor }
        }

        Behavior on width {
            NumberAnimation {
                duration: 520
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: shimmer
            visible: BatteryService.isCharging && rootItem.panelOpen
            width: BatteryService.isOneshotCharging ? 64 : 44
            height: parent.height
            radius: parent.radius

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(1, 1, 1,
                                   BatteryService.isOneshotCharging ? 0.42 : 0.24)
                }
                GradientStop { position: 1.0; color: "transparent" }
            }

            SequentialAnimation on x {
                loops: Animation.Infinite
                running: shimmer.visible
                NumberAnimation {
                    from: -70
                    to: barFill.width + 10
                    duration: BatteryService.isOneshotCharging ? 1450 : 2400
                    easing.type: Easing.InOutSine
                }
                PauseAnimation {
                    duration: BatteryService.isOneshotCharging ? 320 : 700
                }
            }
        }
    }

    Rectangle {
        anchors.fill: barFill
        anchors.margins: -3
        visible: BatteryService.isOneshotCharging && rootItem.panelOpen
        radius: height / 2
        color: "transparent"
        border.width: 1
        border.color: rootItem.oneshotColor
        opacity: 0

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: visible
            NumberAnimation { from: 0; to: 0.45; duration: 1100; easing.type: Easing.InOutSine }
            NumberAnimation { from: 0.45; to: 0; duration: 1100; easing.type: Easing.InOutSine }
        }
    }
}
