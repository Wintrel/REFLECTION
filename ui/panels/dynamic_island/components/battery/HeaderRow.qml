import "core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

Item {
    id: headerRow
    property Item rootItem

    height: 32

    opacity: rootItem.panelOpen ? 1 : 0
    transform: Translate {
        y: rootItem.panelOpen ? 0 : 8
        Behavior on y {
            NumberAnimation {
                duration: rootItem.motionSlow
                easing.type: Easing.OutExpo
            }
        }
    }
    Behavior on opacity { NumberAnimation { duration: rootItem.motionMedium } }

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        spacing: 10
        
        // Music icon container
        Item {
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                anchors.centerIn: parent
                text: "music_note"
                font.family: rootItem.iconFont
                font.pixelSize: 17
                color: rootItem.theme ? rootItem.theme.accentMusic : rootItem.textSub
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
                        islandWidget.islandState = State.IslandState.expanded;
                }
            }
        }

        // Percentage text
        Text {
            id: percentageText
            text: Math.round(rootItem.percentage) + "%"
            font.family: rootItem.mainFont
            font.pixelSize: 28
            font.weight: Font.DemiBold
            font.letterSpacing: -0.5
            color: BatteryService.isOneshotCharging ? rootItem.oneshotColor : rootItem.textMain
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: rootItem.motionSlow } }

            layer.enabled: rootItem.panelOpen
            layer.effect: Glow {
                radius: 7
                samples: 15
                color: Qt.rgba(percentageText.color.r, percentageText.color.g, percentageText.color.b, 0.24)
                transparentBorder: true
            }
        }

        // Status Subtext
        Text {
            text: {
                if (BatteryService.isOneshotCharging) return "One-Shot Override";
                if (BatteryService.isCharging) return "Charging";
                if (BatteryService.isOnAC && BatteryService.status === "Full") return "Fully Charged";
                if (BatteryService.isOnAC && rootItem.percentage >= BatteryService.batteryLimit) return "Limit reached";
                return BatteryService.isOnAC ? "Plugged In" : "On Battery";
            }
            font.family: rootItem.mainFont
            font.pixelSize: 12
            color: rootItem.textSub
            opacity: 0.78
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Right Side: Wattage and AC State
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        spacing: 12

        // Wattage
        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "electric_bolt"
                font.family: rootItem.iconFont
                font.pixelSize: 13
                color: rootItem.wattageColor
                opacity: 0.78
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
            }
            Text {
                text: BatteryService.isOnAC && rootItem.wattage < 2.0 ? "Idle" : rootItem.wattage.toFixed(1) + " W"
                font.family: rootItem.mainFont
                font.pixelSize: 11
                font.weight: Font.Medium
                color: rootItem.wattageColor
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: rootItem.motionMedium } }
            }
        }
        
        // Time Remaining or State
        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: BatteryService.isOnAC ? "power" : "schedule"
                font.family: rootItem.iconFont
                font.pixelSize: 13
                color: rootItem.textSub
                opacity: 0.78
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: BatteryService.isOnAC ? "Plugged In" : (BatteryService.smoothTimeRemaining !== "" ? BatteryService.smoothTimeRemaining : "Calculating…")
                font.family: rootItem.mainFont
                font.pixelSize: 11
                font.weight: Font.Medium
                color: rootItem.textSub
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
