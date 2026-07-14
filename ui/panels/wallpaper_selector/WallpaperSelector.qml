import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../components" as Components
import "../../../core" as Core
import "../../../core/state" as State
import "../../../core/services/system"

Scope {
    Variants {
        model: Quickshell.screens
        
        delegate: PanelWindow {
            id: selectorWindow
            required property var modelData
            screen: modelData
            
            Core.Theme { id: theme }

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            
            color: "transparent"
            visible: State.GlobalStates.wallpaperSelectorOpen
            onVisibleChanged: {
                if (visible) {
                    WallpaperService.refreshWallpapers()
                }
            }
            
            // Background blur/dim
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.8)
                opacity: State.GlobalStates.wallpaperSelectorOpen ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: State.GlobalStates.wallpaperSelectorOpen = false
                }
            }
            
            // Main Container
            Rectangle {
                width: Math.min(parent.width * 0.8, 1200)
                height: Math.min(parent.height * 0.8, 800)
                anchors.centerIn: parent
                
                color: theme.bgInner
                radius: 16
                border.width: 1
                border.color: Qt.rgba(theme.textSub.r, theme.textSub.g, theme.textSub.b, 0.2)
                
                clip: true
                
                scale: State.GlobalStates.wallpaperSelectorOpen ? 1 : 0.95
                opacity: State.GlobalStates.wallpaperSelectorOpen ? 1 : 0
                Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20
                    
                    Text {
                        text: "Wallpaper Selector"
                        font.family: theme.fontMain
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: theme.textMain
                    }
                    
                    Text {
                        text: "Select an image from ~/Pictures/Wallpapers to apply it."
                        font.family: theme.fontMain
                        font.pixelSize: 14
                        color: theme.textSub
                    }
                    
                    GridView {
                        id: grid
                        width: parent.width
                        height: parent.height - 80
                        
                        // Fix weird gap: size cells to perfectly fit 4 columns
                        cellWidth: Math.floor(width / 4)
                        cellHeight: Math.floor(cellWidth * 0.65)
                        
                        model: WallpaperService.wallpapers
                        
                        delegate: Item {
                            width: grid.cellWidth
                            height: grid.cellHeight
                            
                            Rectangle {
                                id: cardRect
                                anchors.fill: parent
                                anchors.margins: 10
                                radius: 12
                                color: Qt.rgba(0, 0, 0, 0.5)
                                
                                property bool isActive: modelData === WallpaperService.currentWallpaper
                                
                                border.width: mouseArea.containsMouse || isActive ? 2 : 1
                                border.color: isActive ? theme.accentPrimary : (mouseArea.containsMouse ? theme.textMain : Qt.rgba(theme.textSub.r, theme.textSub.g, theme.textSub.b, 0.2))
                                Behavior on border.color { ColorAnimation { duration: 200 } }
                                
                                clip: true
                                
                                Image {
                                    anchors.fill: parent
                                    source: modelData
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: Qt.rgba(0, 0, 0, 0.3)
                                        opacity: mouseArea.containsMouse || cardRect.isActive ? 0 : 1
                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                    }
                                }
                                
                                // Active Indicator Badge
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    anchors.margins: 8
                                    width: 70
                                    height: 24
                                    radius: 12
                                    color: theme.accentPrimary
                                    opacity: cardRect.isActive ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Active"
                                        font.family: theme.fontMain
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: "#000000"
                                    }
                                }
                                
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        WallpaperService.setWallpaper(modelData);
                                        State.GlobalStates.wallpaperSelectorOpen = false;
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Close button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 20
                    color: closeArea.containsMouse ? Qt.rgba(1, 0, 0, 0.2) : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 16
                        color: closeArea.containsMouse ? "#ff4444" : theme.textSub
                    }
                    
                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: State.GlobalStates.wallpaperSelectorOpen = false
                    }
                }
            }
        }
    }
}
