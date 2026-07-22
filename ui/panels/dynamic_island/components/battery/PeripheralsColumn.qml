import QtQuick
import "../../../../../core/services/system"

Column {
    id: peripheralsColumn
    property Item rootItem

    spacing: 8

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

    Text {
        text: "CONNECTED DEVICES"
        font.family: rootItem.mainFont
        font.pixelSize: 10
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 0.8
        color: rootItem.textSub
        opacity: 0.6
        visible: BatteryService.peripheralBatteries.length > 0
    }

    Repeater {
        model: BatteryService.peripheralBatteries

        delegate: Item {
            required property var modelData

            width: parent.width
            height: 20

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    text: modelData.icon || "speaker"
                    font.family: rootItem.iconFont
                    font.pixelSize: 14
                    color: rootItem.textSub
                    opacity: 0.6
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: modelData.name || "Device"
                    font.family: rootItem.mainFont
                    font.pixelSize: 12
                    color: rootItem.textSub
                    opacity: 0.9
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Text {
                id: pctText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.percentage + "%"
                font.family: rootItem.mainFont
                font.pixelSize: 11
                color: rootItem.textSub
                opacity: 0.8
            }

            Rectangle {
                anchors.right: pctText.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 100
                height: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.08)
                
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * (Number(modelData.percentage) / 100.0)
                    radius: 2
                    color: {
                        var pct = Number(modelData.percentage) || 0;
                        if (pct > 20) return rootItem.textSub;
                        if (pct > 10) return "#D99672";
                        return "#D96673";
                    }
                }
            }
        }
    }
}
