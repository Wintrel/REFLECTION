import QtQuick
import "../../../../core" as Core
import "../../../../core/state" as State
import "../../../components" as Components

Item {
    id: root
    
    property int islandState: 0
    property var mprisPlayer: null
    property var theme: null
    
    opacity: root.islandState < 2 ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: root.theme ? root.theme.animDuration / 2 : 150 } }
    
    property bool isPlaying: root.mprisPlayer && root.mprisPlayer.isPlaying
    property bool hasNotifs: State.GlobalStates.notificationHistory.count > 0
    
    // Abstract Ambient Indicators (Based on Reflection Philosophy)
    
    // Left side: Music Ambient Indicator (Waveform)
    Item {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        opacity: root.isPlaying ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        
        Row {
            anchors.centerIn: parent
            spacing: 3
            visible: root.isPlaying
            
            Repeater {
                model: 3
                Rectangle {
                    width: 3
                    radius: 1.5
                    color: root.theme ? root.theme.colorMusic : "#5611f8"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    SequentialAnimation on height {
                        loops: Animation.Infinite
                        running: root.isPlaying
                        NumberAnimation { 
                            from: 4; to: [14, 8, 16][index]; 
                            duration: [300, 250, 350][index]; 
                            easing.type: Easing.InOutQuad 
                        }
                        NumberAnimation { 
                            from: [14, 8, 16][index]; to: 4; 
                            duration: [300, 250, 350][index]; 
                            easing.type: Easing.InOutQuad 
                        }
                    }
                }
            }
        }
    }
    
    // Right side: Notification Ambient Indicator (Dot / Counter)
    Item {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        opacity: root.hasNotifs ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        
        Rectangle {
            anchors.centerIn: parent
            width: Math.max(16, notifText.contentWidth + 8)
            height: 16
            radius: 8
            color: root.theme ? root.theme.colorNotification : "#710cee"
            
            Text {
                id: notifText
                anchors.centerIn: parent
                text: State.GlobalStates.notificationHistory.count.toString()
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 10
                font.bold: true
                color: "#FFFFFF"
            }
        }
    }
}
