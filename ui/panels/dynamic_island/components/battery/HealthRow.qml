import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

Item {
    id: healthRow
    property Item rootItem

    height: 20

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            NumberAnimation { duration: rootItem.motionSlow; easing.type: Easing.OutExpo }
        }
    }
    Behavior on opacity { NumberAnimation { duration: rootItem.motionMedium } }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
            text: "health_and_safety"
            font.family: rootItem.iconFont
            font.pixelSize: 15
            color: rootItem.textSub
            opacity: 0.72
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "Battery Health"
            font.family: rootItem.mainFont
            font.pixelSize: 13
            color: rootItem.textSub
            opacity: 0.9
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: BatteryService.health + "%"
        font.family: rootItem.mainFont
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: rootItem.textMain
        opacity: 0.9
    }
}
