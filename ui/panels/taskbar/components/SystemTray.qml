import QtQuick
import Quickshell
import "../../../../core/state" as State
import "../../../../core/services/system"

Item {
    id: root
    
    property var theme
    
    width: trayRow.width + 16
    height: 32
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: ma.containsMouse ? (root.theme ? Qt.rgba(255,255,255,0.1) : "#222") : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                State.GlobalStates.controlCenterOpen = !State.GlobalStates.controlCenterOpen;
            }
        }
    }
    
    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 12
        
        // Clock
        Clock {
            theme: root.theme
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
