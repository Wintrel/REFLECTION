import QtQuick
import "../../../../../core/services/system"

Rectangle {
    id: profileRow
    property Item rootItem

    width: parent.width
    height: 28
    radius: height / 2
    color: rootItem.surfaceLow
    border.width: 1
    border.color: rootItem.hairline

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            SequentialAnimation {
                PauseAnimation { duration: 120 }
                NumberAnimation { duration: rootItem.motionSlow; easing.type: Easing.OutExpo }
            }
        }
    }
    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: 120 }
            NumberAnimation { duration: rootItem.motionMedium }
        }
    }

    Row {
        anchors.fill: parent
        
        Repeater {
            model: [
                { label: "Quiet", icon: "radio_button_unchecked" },
                { label: "Balanced", icon: "grid_view" },
                { label: "Performance", icon: "bolt" }
            ]

            delegate: Rectangle {
                required property var modelData
                property bool isActive: BatteryService.asusProfile === modelData.label
                property bool isHovered: profileArea.containsMouse
                property bool isPressed: profileArea.pressed

                width: profileRow.width / 3
                height: parent.height
                radius: height / 2
                color: isActive
                       ? rootItem.surfaceHigh
                       : (isPressed
                          ? Qt.rgba(1, 1, 1, 0.06)
                          : (isHovered ? rootItem.surfaceLow : "transparent"))
                
                border.width: isActive ? 1 : 0
                border.color: isActive ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                
                scale: isPressed ? 0.97 : 1

                Behavior on color { ColorAnimation { duration: rootItem.motionFast } }
                Behavior on border.color { ColorAnimation { duration: rootItem.motionFast } }
                Behavior on scale { NumberAnimation { duration: rootItem.motionFast; easing.type: Easing.OutCubic } }

                Row {
                    id: profileLabel
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: modelData.icon
                        font.family: rootItem.iconFont
                        font.pixelSize: 13
                        color: parent.parent.isActive ? rootItem.textMain : rootItem.textSub
                        opacity: parent.parent.isActive ? 1 : 0.78
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.label
                        font.family: rootItem.mainFont
                        font.pixelSize: 11
                        font.weight: parent.parent.isActive ? Font.DemiBold : Font.Medium
                        color: parent.parent.isActive ? rootItem.textMain : rootItem.textSub
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: profileArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BatteryService.setAsusProfile(modelData.label)
                }
            }
        }
    }
}
