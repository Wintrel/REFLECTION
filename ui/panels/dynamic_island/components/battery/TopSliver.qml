import QtQuick
import "../../../../../core/services/system"

Item {
    id: topSliver
    property Item rootItem

    height: 20

    Item {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 24

        Text {
            anchors.centerIn: parent
            text: "music_note"
            font.family: rootItem.iconFont
            font.pixelSize: 17
            color: rootItem.theme ? rootItem.theme.colorMusic : rootItem.textSub
            opacity: musicArea.pressed ? 0.55 : (musicArea.containsMouse ? 0.95 : 0.68)
            scale: musicArea.pressed ? 0.92 : (musicArea.containsMouse ? 1.06 : 1)

            Behavior on opacity { NumberAnimation { duration: rootItem.motionFast } }
            Behavior on scale { NumberAnimation { duration: rootItem.motionFast; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: musicArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (typeof islandWidget !== "undefined")
                    islandWidget.islandState = 2;
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Text {
            text: Math.round(rootItem.percentage) + "%"
            font.family: rootItem.mainFont
            font.pixelSize: 12
            font.weight: Font.Medium
            color: rootItem.statusColor
            opacity: 0.9
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
        }

        Text {
            text: rootItem.batteryIcon
            font.family: rootItem.iconFont
            font.pixelSize: 17
            color: rootItem.statusColor
            opacity: 0.9
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
        }
    }
}
