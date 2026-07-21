import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../../../core/state" as State
import "../../../../core/services/system"

Item {
    id: root
    
    property var theme
    
    width: trayRow.width + 48
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
        
        // Active System Tray Icons
        Repeater {
            model: SystemTray.items.values
            
            delegate: Item {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                
                property var itemData: modelData
                
                IconImage {
                    id: trayIcon
                    anchors.fill: parent
                    source: itemData.icon
                    
                    // Tint the icon if you want a monochrome look, or leave it native.
                    // Leaving native for now so app colors (like Discord blurple) show up.
                }
                
                MouseArea {
                    id: iconMa
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    
                    onClicked: {
                        itemData.activate();
                    }
                }
                
                Rectangle {
                    anchors.fill: iconMa
                    radius: 4
                    color: iconMa.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    z: -1
                }
            }
        }
        
        // Clock
        Clock {
            theme: root.theme
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
