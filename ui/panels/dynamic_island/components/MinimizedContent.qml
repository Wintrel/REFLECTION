import QtQuick
import "../../../../core" as Core
import "../../../components" as Components

Item {
    id: root
    
    property int islandState: 0
    property var mprisPlayer: null
    property var theme: null
    
    opacity: root.islandState < 2 ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: root.theme ? root.theme.animDuration / 2 : 150 } }
    
    // Left: Notification Dot
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: root.theme ? root.theme.colorNotification : "#710cee"
    }
    
    // Right: Music Progress
    Components.CircularProgress {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        
        value: root.mprisPlayer ? root.mprisPlayer.position : 0
        maximumValue: root.mprisPlayer ? root.mprisPlayer.length : 100
        color: root.theme ? root.theme.colorMusic : "#5611f8"
    }
}
