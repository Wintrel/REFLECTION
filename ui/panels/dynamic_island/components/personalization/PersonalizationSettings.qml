import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    property int currentTab: 0 // 0: Theme, 1: Wallpaper, 2: Geometry & Effects
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Tab Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Repeater {
                model: ["Theme & Colors", "Wallpaper", "Geometry & Effects"]
                
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 8
                    
                    property bool isSelected: root.currentTab === index
                    
                    color: isSelected ? (root.theme ? root.theme.accentPrimary : "#8C8C9E") : Qt.rgba(255, 255, 255, 0.05)
                    border.width: isSelected ? 0 : (maTab.containsMouse ? 1 : 0)
                    border.color: Qt.rgba(255, 255, 255, 0.2)
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: isSelected ? Font.Bold : Font.Normal
                        color: isSelected ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                    }
                    
                    MouseArea {
                        id: maTab
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = index
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(255, 255, 255, 0.1)
        }
        
        // Content Area
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentCol.implicitHeight
            clip: true
            
            flickDeceleration: 1000
            maximumFlickVelocity: 4000
            boundsBehavior: Flickable.DragAndOvershootBounds
            
            Behavior on contentY {
                enabled: !dragging && !flicking
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
            
            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 24
                
                // --- Tab 0: Theme & Colors ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    visible: root.currentTab === 0
                    
                    ThemeCard { theme: root.theme }
                    CustomThemeEditor { theme: root.theme }
                }
                
                // --- Tab 1: Wallpaper ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    visible: root.currentTab === 1
                    
                    WallpaperCard { theme: root.theme }
                }
                
                // --- Tab 2: Geometry & Effects ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    visible: root.currentTab === 2
                    
                    GeometryCard { theme: root.theme }
                    EdgeLightingCard { theme: root.theme }
                }
                
                Item { Layout.preferredHeight: 40 } // Bottom padding
            }
        }
    }
}
