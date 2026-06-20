import QtQuick
import Quickshell

Item {
    id: root
    
    property var theme
    property string icon: ""
    property string label: ""
    
    height: 48
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 12
        color: root.theme ? Qt.rgba(255,255,255,0.05) : "#111"
        border.width: 1
        border.color: root.theme ? Qt.rgba(255,255,255,0.05) : "#222"
        
        Row {
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: root.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: root.theme ? root.theme.textMain : "#FFF"
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: root.label
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 13
                color: root.theme ? root.theme.textMain : "#FFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: ma.pressed ? Qt.rgba(0,0,0,0.2) : (ma.containsMouse ? Qt.rgba(255,255,255,0.05) : "transparent")
            Behavior on color { ColorAnimation { duration: 100 } }
        }
        
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log("Action clicked: " + root.label);
            }
        }
    }
}
