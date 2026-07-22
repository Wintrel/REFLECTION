import QtQuick
import "../../../../../core/services/system"

Column {
    id: statsColumn
    property Item rootItem

    spacing: 8

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            SequentialAnimation {
                PauseAnimation { duration: 80 }
                NumberAnimation { duration: rootItem.motionSlow; easing.type: Easing.OutExpo }
            }
        }
    }
    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: 80 }
            NumberAnimation { duration: rootItem.motionMedium }
        }
    }

    Item {
        width: parent.width
        height: 18

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: "schedule"
                font.family: rootItem.iconFont
                font.pixelSize: 14
                color: rootItem.textSub
                opacity: 0.72
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: BatteryService.smoothTimeRemaining !== ""
                      ? BatteryService.smoothTimeRemaining
                        + (BatteryService.smoothTimeLabel !== ""
                           ? " " + BatteryService.smoothTimeLabel
                           : "")
                      : "Calculating…"
                font.family: rootItem.mainFont
                font.pixelSize: 12
                color: rootItem.textSub
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Text {
                text: "electric_bolt"
                font.family: rootItem.iconFont
                font.pixelSize: 14
                color: rootItem.wattageColor
                opacity: 0.78
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
            }
            Text {
                text: BatteryService.isOnAC && rootItem.wattage < 2.0
                      ? "Idle"
                      : rootItem.wattage.toFixed(1) + " W"
                font.family: rootItem.mainFont
                font.pixelSize: 12
                font.weight: Font.Medium
                color: rootItem.wattageColor
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
            }
        }
    }

    Item {
        width: parent.width
        height: 24

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: "health_and_safety"
                font.family: rootItem.iconFont
                font.pixelSize: 14
                color: rootItem.textSub
                opacity: 0.72
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Health " + BatteryService.health + "%"
                font.family: rootItem.mainFont
                font.pixelSize: 12
                color: rootItem.textSub
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: "battery_saver"
                font.family: rootItem.iconFont
                font.pixelSize: 14
                color: rootItem.textSub
                opacity: 0.72
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Limit"
                font.family: rootItem.mainFont
                font.pixelSize: 10
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 0.6
                color: rootItem.textSub
                opacity: 0.78
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: segmentRow.width + 6
                height: 22
                radius: 7
                color: Qt.rgba(1, 1, 1, 0.04)
                border.width: 1
                border.color: rootItem.hairline
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: segmentRow
                    anchors.centerIn: parent
                    spacing: 2

                    Rectangle {
                        property bool isActive: BatteryService.batteryLimit <= 60
                                                && !BatteryService.isOneshotCharging
                        width: 36
                        height: 18
                        radius: 5
                        color: isActive ? rootItem.surfaceHigh : "transparent"
                        border.width: isActive ? 1 : 0
                        border.color: isActive ? Qt.rgba(1, 1, 1, 0.18) : "transparent"

                        Behavior on color { ColorAnimation { duration: rootItem.motionFast } }
                        Behavior on border.color { ColorAnimation { duration: rootItem.motionFast } }

                        Text {
                            anchors.centerIn: parent
                            text: "60%"
                            font.family: rootItem.mainFont
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: parent.isActive ? rootItem.textMain : rootItem.textSub
                            opacity: parent.isActive ? 1 : 0.78
                            Behavior on color { ColorAnimation { duration: rootItem.motionFast } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BatteryService.setChargeLimit(60)
                        }
                    }

                    Rectangle {
                        property bool isActive: BatteryService.isOneshotCharging
                        width: chargeLabel.width + 12
                        height: 18
                        radius: 5
                        color: isActive
                               ? Qt.rgba(rootItem.activeChargingColor.r,
                                         rootItem.activeChargingColor.g,
                                         rootItem.activeChargingColor.b,
                                         0.92)
                               : "transparent"

                        Behavior on color { ColorAnimation { duration: rootItem.motionFast } }

                        Row {
                            id: chargeLabel
                            anchors.centerIn: parent
                            spacing: 3

                            Text {
                                text: parent.parent.isActive
                                      ? (chargeArea.containsMouse ? "close" : "bolt")
                                      : "bolt"
                                font.family: rootItem.iconFont
                                font.pixelSize: 11
                                color: parent.parent.isActive ? "#07090E" : rootItem.textSub
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: parent.parent.isActive
                                      ? (chargeArea.containsMouse ? "Cancel" : "Charging…")
                                      : "Full Once"
                                font.family: rootItem.mainFont
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: parent.parent.isActive ? "#07090E" : rootItem.textSub
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: chargeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (BatteryService.isOneshotCharging)
                                    BatteryService.cancelOneshot();
                                else
                                    BatteryService.chargeFullOnce();
                            }
                        }
                    }
                }
            }
        }
    }
}
