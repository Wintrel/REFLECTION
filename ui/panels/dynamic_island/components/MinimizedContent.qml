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
        width: notifRow.width
        height: 16
        opacity: root.hasNotifs ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        
        Row {
            id: notifRow
            anchors.centerIn: parent
            spacing: 6
            
            // Sleek pulsing dot
            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: root.theme ? root.theme.colorNotification : "#710cee"
                anchors.verticalCenter: parent.verticalCenter
                
                // Outer breathing glow ring
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: parent.radius
                    color: parent.color
                    
                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: root.hasNotifs && root.opacity > 0
                        NumberAnimation { from: 1.0; to: 2.8; duration: 1500; easing.type: Easing.OutQuad }
                    }
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.hasNotifs && root.opacity > 0
                        NumberAnimation { from: 0.6; to: 0.0; duration: 1500; easing.type: Easing.OutQuad }
                    }
                }
            }
            
            // Clean typography for the count (no heavy background block)
            Text {
                text: State.GlobalStates.notificationHistory.count.toString()
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: root.theme ? root.theme.textMain : "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
