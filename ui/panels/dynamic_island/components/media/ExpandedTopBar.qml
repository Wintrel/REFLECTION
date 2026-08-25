import "../../../../../core/state" as State
import QtQuick
import "../../../../../core" as Core
import "../../../../../core/services/system"

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null

    height: 20
    
    property bool isVisible: root.islandState === State.IslandState.expanded
    opacity: (root.islandState === State.IslandState.expanded) ? 1 : 0
    transform: Translate {
        y: (root.islandState === State.IslandState.expanded) ? 0 : -5
        Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
    }
    Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
    
    Item {
        anchors.left: parent.left
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
            id: notifIcon
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
                width: 28
                height: 28
                anchors.verticalCenter: parent.verticalCenter
                visible: root.mprisPlayer && root.mprisPlayer.identity === "Cider"
                
                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: expandMa.containsMouse ? (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255,255,255,0.08)) : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "open_in_full"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
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
            
            Item {
                width: batteryRow.width + 16
                height: 28
                anchors.verticalCenter: parent.verticalCenter
                
                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: batteryMa.containsMouse ? (root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.2) : Qt.rgba(255, 255, 255, 0.12)) : (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.06))
                    border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.5) : Qt.rgba(255, 255, 255, 0.1)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                MouseArea {
                    id: batteryMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.battery; // Switch to Battery View
                        }
                    }
                }
                
                Row {
                    id: batteryRow
                    spacing: 6
                    anchors.centerIn: parent
                    
                    Text {
                        text: BatteryService.percentage + "%"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        color: root.theme ? root.theme.textMain : "#FFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item {
                        width: 22
                        height: 10
                        anchors.verticalCenter: parent.verticalCenter
                        
                        // Battery Body (Outline)
                        Rectangle {
                            width: 20
                            height: 10
                            radius: 3
                            color: "transparent"
                            border.color: root.theme ? root.theme.textSub : "#A6ADC8"
                            border.width: 1
                            
                            // Battery Fill (The juice)
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
                        
                        // Battery Tip
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
        }
    }
}
