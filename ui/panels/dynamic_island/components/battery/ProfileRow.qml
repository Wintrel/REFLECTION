import QtQuick
import "../../../../../core/services/system"

Row {
    id: profileRow
    property Item rootItem

    spacing: 8

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

    Repeater {
        model: [
            { label: "Quiet", icon: "eco" },
            { label: "Balanced", icon: "balance" },
            { label: "Performance", icon: "bolt" }
        ]

        delegate: Rectangle {
            required property var modelData
            property bool isActive: BatteryService.asusProfile === modelData.label
            property bool isHovered: profileArea.containsMouse
            property bool isPressed: profileArea.pressed

            width: profileLabel.width + 20
            height: 27
            radius: height / 2
            color: isActive
                   ? rootItem.surfaceHigh
                   : (isPressed
                      ? Qt.rgba(1, 1, 1, 0.06)
                      : (isHovered ? rootItem.surfaceLow : "transparent"))
            border.width: 1
            border.color: isActive
                          ? Qt.rgba(1, 1, 1, 0.22)
                          : (isHovered ? Qt.rgba(1, 1, 1, 0.15) : rootItem.hairline)
            scale: isPressed ? 0.97 : 1

            Behavior on color { ColorAnimation { duration: rootItem.motionFast } }
            Behavior on border.color { ColorAnimation { duration: rootItem.motionFast } }
            Behavior on scale { NumberAnimation { duration: rootItem.motionFast; easing.type: Easing.OutCubic } }

            Row {
                id: profileLabel
                anchors.centerIn: parent
                spacing: 5

                Rectangle {
                    visible: parent.parent.isActive
                    width: 3
                    height: 3
                    radius: 1.5
                    color: rootItem.barColor
                    anchors.verticalCenter: parent.verticalCenter
                }

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
