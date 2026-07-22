import QtQuick
import Quickshell

Item {
    id: root
    
    property var theme
    property string icon: ""
    property string label: ""
    property bool isActive: false
    signal clicked()
    signal rightClicked()
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 16
        
        // Background State Machine
        color: ma.pressed ? (root.theme ? root.theme.accentPrimary : "#ff9900") 
             : (root.isActive ? (root.theme ? root.theme.accentSecondary : "#5611f8") 
                              : (root.theme ? Qt.rgba(255,255,255,0.05) : "#111"))
                              
        // Border Hover Glow State Machine
        border.width: 1
        border.color: (ma.pressed || root.isActive) ? "transparent" 
                    : (ma.containsMouse ? (root.theme ? root.theme.accentPrimary : "#ff9900") 
                                        : (root.theme ? Qt.rgba(255,255,255,0.05) : "#222"))

        Behavior on color { ColorAnimation { duration: 250 } }
        Behavior on border.color { ColorAnimation { duration: 250 } }
        
        Row {
            anchors.centerIn: parent
            spacing: 12
            
            Text {
                text: root.icon
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 22
                color: ma.pressed ? (root.theme ? root.theme.bgBase : "#000") : (root.theme ? root.theme.textMain : "#FFF")
                Behavior on color { ColorAnimation { duration: 250 } }
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: root.label
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                font.bold: true
                color: ma.pressed ? (root.theme ? root.theme.bgBase : "#000") : (root.theme ? root.theme.textMain : "#FFF")
                Behavior on color { ColorAnimation { duration: 250 } }
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.rightClicked()
                } else {
                    root.clicked()
                }
            }
        }
    }
}
