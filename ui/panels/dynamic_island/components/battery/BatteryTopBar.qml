import "../../../../../core/state" as State
import QtQuick
import "../../../../../core" as Core
import "../../../../../core/services/system"

Item {
    id: root

    property var theme: null
    property int islandState: State.IslandState.battery

    height: 28

    // ── Left Side: Quick Switchers (Media, Notifications) ─────────
    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Switch to Media / Music Expanded View
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: mediaMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255,255,255,0.08)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "music_note"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: mediaMa.containsMouse ? (root.theme ? root.theme.accentMusic : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: mediaMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.expanded;
                    }
                }
            }
        }

        // Switch to Notification History
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: notifMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255,255,255,0.08)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "notifications"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: notifMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: notifMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.notificationHistory;
                    }
                }
            }
        }

        // Divider
        Rectangle {
            width: 1
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            color: root.theme ? Qt.rgba(255,255,255,0.12) : Qt.rgba(1,1,1,0.1)
        }

        // Section Title
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "System & Battery"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.theme ? root.theme.textSub : "#A6ADC8"
        }
    }

    // ── Right Side: Live Stats & Close Button ─────────────────────
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        // Wattage / Time Remaining Pill
        Item {
            width: wattageRow.width + 16
            height: 26
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 13
                color: root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.06)
                border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.3) : Qt.rgba(255, 255, 255, 0.08)
                border.width: 1
            }

            Row {
                id: wattageRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: BatteryService.isCharging ? "electric_bolt" : (BatteryService.isOnAC ? "power" : "schedule")
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 13
                    color: root.theme ? root.theme.accentPrimary : "#79D6A1"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: {
                        var w = Math.abs(Number(BatteryService.smoothWattage) || 0);
                        var wStr = (BatteryService.isOnAC && w < 2.0) ? "" : (w.toFixed(1) + " W");
                        var tStr = BatteryService.isOnAC ? "Plugged In" : (BatteryService.smoothTimeRemaining !== "" ? BatteryService.smoothTimeRemaining : "");
                        if (wStr !== "" && tStr !== "") return wStr + " • " + tStr;
                        return wStr !== "" ? wStr : tStr;
                    }
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: root.theme ? root.theme.textMain : "#FFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Close / Minimize Island Button
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: closeMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255,255,255,0.08)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "keyboard_arrow_up"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 20
                color: closeMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: closeMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.idle;
                    }
                }
            }
        }
    }
}

