import QtQuick
import "../../../../../core" as Core
import "../../../../../core/services/system"

Item {
    id: root

    property int islandState: 0
    property var mprisPlayer: null
    property var theme: null

    height: 20
    
    property bool isVisible: root.islandState === 2
    opacity: (root.islandState === 2) ? 1 : 0
    transform: Translate {
        y: (root.islandState === 2) ? 0 : -5
        Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
    }
    Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
    
    Item {
        anchors.left: parent.left
        width: 32
        height: 24
        anchors.verticalCenter: parent.verticalCenter
        
        Text {
            id: notifIcon
            anchors.centerIn: parent
            text: "notifications"
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 18
            color: root.theme ? root.theme.accentNotification : "#710cee"
            scale: notifMa.pressed ? 0.9 : (notifMa.containsMouse ? 1.1 : 1)
            opacity: notifMa.pressed ? 0.7 : 1
            Behavior on scale { NumberAnimation { duration: 150 } }
        }
        
        MouseArea {
            id: notifMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (typeof islandWidget !== "undefined") {
                    islandWidget.islandState = 4;
                }
            }
        }
    }
    
    Item {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: batteryRow.width + expandBtn.width + 16
        height: batteryRow.height
        
        Row {
            id: expandRow
            anchors.right: parent.right
            spacing: 16
            
            Item {
                id: expandBtn
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                visible: root.mprisPlayer && root.mprisPlayer.identity === "Cider"
                
                Text {
                    anchors.centerIn: parent
                    text: "open_in_full"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: root.theme ? root.theme.textSub : "#A6ADC8"
                    scale: expandMa.pressed ? 0.9 : (expandMa.containsMouse ? 1.1 : 1)
                    opacity: expandMa.pressed ? 0.7 : 1
                    Behavior on scale { NumberAnimation { duration: 150 } }
                }
                
                MouseArea {
                    id: expandMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = 13;
                        }
                    }
                }
            }
            
            Item {
                width: batteryRow.width
                height: batteryRow.height
                anchors.verticalCenter: parent.verticalCenter
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = 9; // Switch to Battery View
                        }
                    }
                }
                
                Row {
                    id: batteryRow
                    spacing: 6
                    Text {
                        text: BatteryService.percentage + "%"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        color: root.theme ? root.theme.textMain : "#FFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: {
                            if (BatteryService.isCharging) return "battery_charging_full";
                            if (BatteryService.percentage > 80) return "battery_full";
                            if (BatteryService.percentage > 60) return "battery_5_bar";
                            if (BatteryService.percentage > 40) return "battery_4_bar";
                            if (BatteryService.percentage > 20) return "battery_3_bar";
                            if (BatteryService.percentage > 10) return "battery_1_bar";
                            return "battery_alert";
                        }
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: BatteryService.percentage > 20 || BatteryService.isCharging ? (root.theme ? root.theme.textMain : "#FFF") : "#F38BA8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
