import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.ui.panels.launcher

Item {
    id: root
    
    property var theme: null
    
    height: 60
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 12
        border.color: root.theme ? root.theme.colorNotification : "#710cee"
        border.width: 1
        
        Row {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            
            Text {
                text: "search"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 24
                color: root.theme ? root.theme.textMain : "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.7
            }
            
            TextInput {
                id: searchInput
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 40
                
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 20
                color: root.theme ? root.theme.textMain : "#FFFFFF"
                verticalAlignment: TextInput.AlignVCenter
                
                text: AppLauncherState.searchQuery
                onTextChanged: AppLauncherState.searchQuery = text
                
                // Focus management
                focus: AppLauncherState.isOpen
                onVisibleChanged: {
                    if (visible && AppLauncherState.isOpen) {
                        forceActiveFocus();
                    }
                }
                
                Text {
                    text: "Search applications..."
                    color: root.theme ? root.theme.textSub : "#A6ADC8"
                    font: parent.font
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    visible: parent.text.length === 0 && !parent.activeFocus
                    opacity: 0.5
                }
            }
        }
    }
}
