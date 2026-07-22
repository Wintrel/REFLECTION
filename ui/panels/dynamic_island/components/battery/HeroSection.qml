import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

Item {
    id: heroSection
    property Item rootItem

    height: 36

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            NumberAnimation {
                duration: rootItem.motionSlow
                easing.type: Easing.OutExpo
            }
        }
    }
    Behavior on opacity { NumberAnimation { duration: rootItem.motionMedium } }

    Text {
        id: percentageText
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: Math.round(rootItem.percentage) + "%"
        font.family: rootItem.mainFont
        font.pixelSize: 30
        font.weight: Font.Light
        font.letterSpacing: -0.5
        color: BatteryService.isOneshotCharging ? rootItem.oneshotColor : rootItem.textMain

        Behavior on color { ColorAnimation { duration: rootItem.motionSlow } }

        layer.enabled: rootItem.panelOpen
        layer.effect: Glow {
            radius: 7
            samples: 15
            color: Qt.rgba(percentageText.color.r,
                           percentageText.color.g,
                           percentageText.color.b,
                           0.24)
            transparentBorder: true
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        spacing: 5

        Text {
            text: rootItem.statusText
            font.family: rootItem.mainFont
            font.pixelSize: 13
            font.weight: Font.Medium
            color: rootItem.statusColor
            opacity: 0.9
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
        }

        Text {
            text: rootItem.statusIcon
            font.family: rootItem.iconFont
            font.pixelSize: 17
            color: rootItem.statusColor
            opacity: 0.9
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
        }
    }
}
