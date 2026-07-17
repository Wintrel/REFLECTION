import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8
    
    Text {
        text: "Desktop Wallpaper"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: root.theme ? root.theme.textMain : "#FFF"
    }
    
    Text {
        text: "Select a wallpaper for your background. Uses awww daemon for smooth transitions."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }
    
    // Carousel wrapper
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        
        ListView {
            id: wallpaperList
            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            model: WallpaperService.wallpapers
            
            boundsBehavior: Flickable.StopAtBounds
            
            ScrollBar.horizontal: ScrollBar { 
                policy: ScrollBar.AsNeeded
            }
            
            delegate: Rectangle {
                width: 220
                height: 120
                radius: 8
                
                property bool isCurrent: modelData === WallpaperService.currentWallpaper
                
                color: "transparent"
                border.width: isCurrent ? 3 : (maWall.containsMouse ? 2 : 0)
                border.color: isCurrent ? (root.theme ? root.theme.accentPrimary : "#FFF") : (maWall.containsMouse ? Qt.rgba(255, 255, 255, 0.2) : "transparent")
                
                Behavior on border.width { NumberAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                
                // Add margin inside the border to avoid cropping image
                Item {
                    anchors.fill: parent
                    anchors.margins: parent.border.width > 0 ? 3 : 0
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: "#111"
                        clip: true
                        
                        Image {
                            anchors.fill: parent
                            source: modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }
                    }
                }
                
                MouseArea {
                    id: maWall
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        WallpaperService.setWallpaper(modelData, "wipe")
                    }
                }
                
                // Active checkmark
                Rectangle {
                    visible: parent.isCurrent
                    width: 24
                    height: 24
                    radius: 12
                    color: root.theme ? root.theme.accentPrimary : "#FFF"
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 8
                    
                    Text {
                        anchors.centerIn: parent
                        text: "check"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 16
                        color: "#000"
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }
}
