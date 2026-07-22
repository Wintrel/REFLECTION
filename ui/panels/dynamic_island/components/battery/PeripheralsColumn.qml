import QtQuick
import "../../../../../core/services/system"

Column {
    id: peripheralsColumn
    property Item rootItem

    spacing: 5

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            SequentialAnimation {
                PauseAnimation { duration: 160 }
                NumberAnimation { duration: rootItem.motionSlow; easing.type: Easing.OutExpo }
            }
        }
    }
    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: 160 }
            NumberAnimation { duration: rootItem.motionMedium }
        }
    }

    Repeater {
        model: BatteryService.peripheralBatteries

        delegate: Rectangle {
            required property var modelData

            width: parent.width
            height: 32
            radius: 7
            color: rootItem.surfaceLow
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.045)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 7

                Text {
                    text: modelData.icon || "battery_full"
                    font.family: rootItem.iconFont
                    font.pixelSize: 15
                    color: rootItem.textSub
                    opacity: 0.76
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: modelData.name || "Device"
                    font.family: rootItem.mainFont
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: rootItem.textMain
                    opacity: 0.92
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.percentage + "%"
                font.family: rootItem.mainFont
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: {
                    var pct = Number(modelData.percentage) || 0;
                    if (pct > 20)
                        return rootItem.textMain;
                    if (pct > 10)
                        return "#D99672";
                    return "#D96673";
                }
            }
        }
    }
}
