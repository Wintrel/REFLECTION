import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property int currentTab: 0
    property var theme: null
    
    signal closeClicked()
    signal tabSelected(int index)
    
    height: 30
    
    // Close Button (Left)
    Item {
        anchors.left: parent.left
        width: 32
        height: 24
        anchors.verticalCenter: parent.verticalCenter
        
        Text {
            text: "close_fullscreen"
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 18
            color: root.theme ? root.theme.textSub : "#A6ADC8"
            scale: collapseMa.pressed ? 0.9 : (collapseMa.containsMouse ? 1.1 : 1)
            opacity: collapseMa.pressed ? 0.7 : 1
            Behavior on scale { NumberAnimation { duration: 150 } }
            
            MouseArea {
                id: collapseMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeClicked()
            }
        }
    }
    
    // Center Tabs
    Row {
        anchors.centerIn: parent
        spacing: 24
        
        Repeater {
            model: ["Up Next", "Playlists", "For You", "Search", "Lyrics"]
            delegate: Item {
                width: tabTxt.width + 16
                height: 30
                
                Text {
                    id: tabTxt
                    anchors.centerIn: parent
                    text: modelData
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.currentTab === index ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                    opacity: root.currentTab === index ? 1.0 : (tabMa.containsMouse ? 0.8 : 0.5)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.currentTab === index ? parent.width * 0.6 : 0
                    height: 3
                    radius: 1.5
                    color: root.theme ? root.theme.accentPrimary : "#00FFCC"
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                }
                
                MouseArea {
                    id: tabMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.tabSelected(index)
                }
            }
        }
    }
}
