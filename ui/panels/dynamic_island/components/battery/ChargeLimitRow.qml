import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

Column {
    id: chargeLimitRow
    property Item rootItem

    spacing: 8

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            NumberAnimation { duration: rootItem.motionSlow; easing.type: Easing.OutExpo }
        }
    }
    Behavior on opacity { NumberAnimation { duration: rootItem.motionMedium } }

    // Top Label and Full Once button
    Item {
        width: parent.width
        height: 20

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: "battery_saver"
                font.family: rootItem.iconFont
                font.pixelSize: 15
                color: rootItem.textSub
                opacity: 0.72
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Charge Limit"
                font.family: rootItem.mainFont
                font.pixelSize: 13
                color: rootItem.textSub
                opacity: 0.9
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Full Once Button
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            property bool isActive: BatteryService.isOneshotCharging
            width: chargeLabel.width + 24
            height: 20
            radius: height / 2
            color: isActive ? Qt.rgba(rootItem.activeChargingColor.r, rootItem.activeChargingColor.g, rootItem.activeChargingColor.b, 0.15) : "transparent"
            border.width: 1
            border.color: isActive ? Qt.rgba(rootItem.activeChargingColor.r, rootItem.activeChargingColor.g, rootItem.activeChargingColor.b, 0.4) : rootItem.hairline

            Behavior on color { ColorAnimation { duration: rootItem.motionFast } }
            Behavior on border.color { ColorAnimation { duration: rootItem.motionFast } }

            Text {
                id: chargeLabel
                anchors.centerIn: parent
                text: parent.isActive ? (chargeArea.containsMouse ? "Cancel" : "Charging…") : "Full Once"
                font.family: rootItem.mainFont
                font.pixelSize: 11
                font.weight: Font.Medium
                color: parent.isActive ? rootItem.activeChargingColor : rootItem.textSub
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

    // Stepped Slider
    Item {
        width: parent.width
        height: 20

        Rectangle {
            id: sliderTrack
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.08)

            // Fill
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * (BatteryService.batteryLimit / 100.0)
                radius: 2
                color: rootItem.textMain
                opacity: 0.8
                
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
            }

            // Markers
            Repeater {
                model: [60, 80, 100]
                Item {
                    x: parent.width * (modelData / 100.0)
                    y: parent.height / 2
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 6
                        color: rootItem.textSub
                        opacity: 0.5
                    }
                    
                    Text {
                        anchors.top: parent.bottom
                        anchors.topMargin: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData
                        font.family: rootItem.mainFont
                        font.pixelSize: 10
                        color: rootItem.textSub
                        opacity: 0.6
                    }
                }
            }

            // Handle
            Rectangle {
                x: parent.width * (BatteryService.batteryLimit / 100.0) - width / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 14
                radius: 7
                color: rootItem.surfaceLow // Approximate hollow look
                border.width: 2
                border.color: rootItem.textMain
                
                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                
                function setClosestLimit(mouseXPos) {
                    let pct = mouseXPos / width * 100;
                    let closest = 60;
                    let minDist = Math.abs(pct - 60);
                    
                    if (Math.abs(pct - 80) < minDist) {
                        closest = 80;
                        minDist = Math.abs(pct - 80);
                    }
                    if (Math.abs(pct - 100) < minDist) {
                        closest = 100;
                    }
                    if (BatteryService.batteryLimit !== closest) {
                        BatteryService.setChargeLimit(closest);
                    }
                }
                
                onClicked: (mouse) => setClosestLimit(mouse.x)
                onPositionChanged: (mouse) => {
                    if (pressed) setClosestLimit(mouse.x);
                }
            }
        }
    }
}
