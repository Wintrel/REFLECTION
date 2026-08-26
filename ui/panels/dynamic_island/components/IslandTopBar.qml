import "../../../../core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var theme: null
    property string title: ""
    property var mprisPlayer: null

    property bool showQuickSwitchers: true
    property bool showCloseButton: true
    property bool showBatteryPill: false
    property bool showWattagePill: false
    property bool showCiderExpandButton: false
    property bool showClearAllButton: false

    signal clearAllClicked()

    height: 28

    // ── Left Side: Quick Switchers (Media, Notifications, Battery) + Title ─
    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // Media View Switcher
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showQuickSwitchers

            readonly property bool isActive: root.islandState === State.IslandState.expanded
            readonly property bool isHovered: mediaMa.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: parent.isActive 
                       ? (root.theme ? Qt.rgba(root.theme.accentMusic.r, root.theme.accentMusic.g, root.theme.accentMusic.b, 0.22) : Qt.rgba(0.34, 0.07, 0.97, 0.22))
                       : (parent.isHovered ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.08)) : "transparent")
                border.width: parent.isActive ? 1 : 0
                border.color: parent.isActive ? (root.theme ? Qt.rgba(root.theme.accentMusic.r, root.theme.accentMusic.g, root.theme.accentMusic.b, 0.45) : Qt.rgba(0.34, 0.07, 0.97, 0.45)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "music_note"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: parent.isActive 
                       ? (root.theme ? root.theme.accentMusic : "#7C9CFF")
                       : (parent.isHovered ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8"))
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

        // Notifications Switcher
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showQuickSwitchers

            readonly property bool isActive: root.islandState === State.IslandState.notificationHistory
            readonly property bool isHovered: notifMa.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: parent.isActive 
                       ? (root.theme ? Qt.rgba(root.theme.accentNotification.r, root.theme.accentNotification.g, root.theme.accentNotification.b, 0.22) : Qt.rgba(0.44, 0.05, 0.93, 0.22))
                       : (parent.isHovered ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.08)) : "transparent")
                border.width: parent.isActive ? 1 : 0
                border.color: parent.isActive ? (root.theme ? Qt.rgba(root.theme.accentNotification.r, root.theme.accentNotification.g, root.theme.accentNotification.b, 0.45) : Qt.rgba(0.44, 0.05, 0.93, 0.45)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "notifications"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: parent.isActive 
                       ? (root.theme ? root.theme.accentNotification : "#B78CFF")
                       : (parent.isHovered ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8"))
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

        // Battery / Hardware Switcher
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showQuickSwitchers

            readonly property bool isActive: root.islandState === State.IslandState.battery
            readonly property bool isHovered: batterySwitchMa.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: parent.isActive 
                       ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.22) : Qt.rgba(0.47, 0.84, 0.63, 0.22))
                       : (parent.isHovered ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.08)) : "transparent")
                border.width: parent.isActive ? 1 : 0
                border.color: parent.isActive ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.45) : Qt.rgba(0.47, 0.84, 0.63, 0.45)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: BatteryService.isCharging ? "battery_charging_full" : "battery_full"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: parent.isActive 
                       ? (root.theme ? root.theme.accentPrimary : "#79D6A1")
                       : (parent.isHovered ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8"))
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: batterySwitchMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.battery;
                    }
                }
            }
        }

        // Vertical Divider
        Rectangle {
            width: 1
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            color: root.theme ? Qt.rgba(255, 255, 255, 0.12) : Qt.rgba(1, 1, 1, 0.1)
            visible: root.title !== ""
        }

        // Section Title Label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.theme ? root.theme.textSub : "#A6ADC8"
            visible: root.title !== ""
        }
    }

    // ── Right Side: Contextual Info & Universal Minimize Button ───
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Cider Ultra Expanded Button (in Media state)
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showCiderExpandButton && root.mprisPlayer && root.mprisPlayer.identity === "Cider"

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: expandMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.08)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "open_in_full"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: expandMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: expandMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.ciderExpanded;
                    }
                }
            }
        }

        // Clear All Notifications Button (in Notification History state)
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showClearAllButton && State.GlobalStates.notificationHistory.count > 0

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: clearMa.containsMouse ? (root.theme ? Qt.rgba(root.theme.accentNotification.r, root.theme.accentNotification.g, root.theme.accentNotification.b, 0.2) : Qt.rgba(1, 0.3, 0.3, 0.2)) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "delete_sweep"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: clearMa.containsMouse ? (root.theme ? root.theme.accentNotification : "#FF79C6") : (root.theme ? root.theme.textSub : "#A6ADC8")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: clearMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.clearAllClicked();
                }
            }
        }

        // Battery Status Pill (in Media state)
        Item {
            width: mediaBatteryRow.width + 16
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showBatteryPill

            Rectangle {
                anchors.fill: parent
                radius: 13
                color: mediaBatteryMa.containsMouse 
                       ? (root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.2) : Qt.rgba(255, 255, 255, 0.12)) 
                       : (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.06))
                border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.4) : Qt.rgba(255, 255, 255, 0.08)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: mediaBatteryMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.battery;
                    }
                }
            }

            Row {
                id: mediaBatteryRow
                spacing: 6
                anchors.centerIn: parent

                Text {
                    text: BatteryService.percentage + "%"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: root.theme ? root.theme.textMain : "#FFF"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: 22
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 20
                        height: 10
                        radius: 3
                        color: "transparent"
                        border.color: root.theme ? root.theme.textSub : "#A6ADC8"
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: 2
                            width: Math.max(0, (16 * BatteryService.percentage) / 100)
                            radius: 1.5
                            color: BatteryService.isCharging ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : 
                                  (BatteryService.percentage > 20 ? (root.theme ? root.theme.textMain : "#FFF") : "#F38BA8")
                            Behavior on width { NumberAnimation { duration: 300 } }
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        width: 2
                        height: 4
                        radius: 1
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                    }
                }
            }
        }

        // Live Wattage / Time Remaining Pill (in Battery state)
        Item {
            width: wattageRow.width + 16
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showWattagePill

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

        // Universal Close / Minimize Island Button
        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showCloseButton

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: closeMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.08)) : "transparent"
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

