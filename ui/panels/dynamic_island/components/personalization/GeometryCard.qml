import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"
import "../../../control_center/components" as CC

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 16

    Text {
        text: "Island Geometry & Motion"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 18
        font.weight: Font.Bold
        color: root.theme ? root.theme.accentPrimary : "#FFF"
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 20
        
        // Island Style Selector (Floating vs Docked)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Island Style"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                // Floating Island Pill Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: ShellService.floatingIsland 
                           ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.22) : Qt.rgba(0.4, 0.4, 1.0, 0.22))
                           : (maFloating.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(255, 255, 255, 0.02))
                    border.width: 1
                    border.color: ShellService.floatingIsland 
                                  ? (root.theme ? root.theme.accentPrimary : "#8888FF")
                                  : Qt.rgba(255, 255, 255, 0.06)
                    
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "airplay"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: ShellService.floatingIsland ? (root.theme ? root.theme.accentPrimary : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                        
                        Text {
                            text: "Floating Island"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: ShellService.floatingIsland ? Font.Bold : Font.Normal
                            color: ShellService.floatingIsland ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                    }
                    
                    MouseArea {
                        id: maFloating
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellService.setFloatingIsland(true)
                    }
                }
                
                // Docked Notch Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: !ShellService.floatingIsland 
                           ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.22) : Qt.rgba(0.4, 0.4, 1.0, 0.22))
                           : (maDocked.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(255, 255, 255, 0.02))
                    border.width: 1
                    border.color: !ShellService.floatingIsland 
                                  ? (root.theme ? root.theme.accentPrimary : "#8888FF")
                                  : Qt.rgba(255, 255, 255, 0.06)
                    
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "vertical_align_top"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: !ShellService.floatingIsland ? (root.theme ? root.theme.accentPrimary : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                        
                        Text {
                            text: "Docked Notch"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: !ShellService.floatingIsland ? Font.Bold : Font.Normal
                            color: !ShellService.floatingIsland ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                    }
                    
                    MouseArea {
                        id: maDocked
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellService.setFloatingIsland(false)
                    }
                }
            }
        }
        
        // Top Margin / Elevation Offset (when floating)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: ShellService.floatingIsland
            
            Text {
                text: "Top Screen Offset: " + ShellService.islandTopMargin + "px"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "vertical_align_bottom"
                valueText: ShellService.islandTopMargin + " px"
                value: (ShellService.islandTopMargin / 36.0) * 100
                
                onValueChangedByUser: (val) => {
                    var margin = Math.round((val / 100.0) * 36);
                    ShellService.setIslandTopMargin(margin);
                }
            }
        }
        
        // Expanded Floating Corner Radius (when floating)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: ShellService.floatingIsland
            
            Text {
                text: "Expanded Corner Radius: " + ShellService.radiusIslandFloating + "px"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "rounded_corner"
                valueText: ShellService.radiusIslandFloating + " px"
                value: ((ShellService.radiusIslandFloating - 12) / 24.0) * 100
                
                onValueChangedByUser: (val) => {
                    var rad = Math.round(12 + (val / 100.0) * 24);
                    ShellService.setRadiusIslandFloating(rad);
                }
            }
        }
        
        // Docked Corner Roundness (when docked)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: !ShellService.floatingIsland
            
            Text {
                text: "Docked Bezel Radius: " + Math.round(ThemeService.radiusIsland) + "px"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "rounded_corner"
                valueText: Math.round(ThemeService.radiusIsland) + " px"
                value: (ThemeService.radiusIsland / 24.0) * 100
                
                onValueChangedByUser: (val) => {
                    var rad = Math.round((val / 100.0) * 24);
                    ThemeService.updateGeometry(rad, -1);
                }
            }
        }
        
        // Animation Duration
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Animation Duration: " + Math.round(ThemeService.animDuration) + "ms"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "animation"
                valueText: Math.round(ThemeService.animDuration) + " ms"
                value: ((ThemeService.animDuration - 100) / 900.0) * 100
                
                onValueChangedByUser: (val) => {
                    var dur = Math.round(100 + (val / 100.0) * 900);
                    ThemeService.updateGeometry(-1, dur);
                }
            }
        }

        // Spring Micro-Bounce (Overshoot)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Spring Micro-Bounce: " + Math.round(ShellService.islandBounceIntensity * 100) + "%"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "speed"
                valueText: Math.round(ShellService.islandBounceIntensity * 100) + "%"
                value: (ShellService.islandBounceIntensity / 0.8) * 100
                
                onValueChangedByUser: (val) => {
                    var bounce = (val / 100.0) * 0.8;
                    ShellService.setIslandBounceIntensity(bounce);
                }
            }
        }

        // --- TASKBAR GEOMETRY & STYLE ---
        Item { Layout.preferredHeight: 12 }

        Text {
            text: "Taskbar Geometry & Style"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: root.theme ? root.theme.accentPrimary : "#FFF"
        }

        // Taskbar Style Selector (Floating vs Docked)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Taskbar Style"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                // Floating Dock Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: ShellService.floatingTaskbar 
                           ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.22) : Qt.rgba(0.4, 0.4, 1.0, 0.22))
                           : (maFloatingTb.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(255, 255, 255, 0.02))
                    border.width: 1
                    border.color: ShellService.floatingTaskbar 
                                  ? (root.theme ? root.theme.accentPrimary : "#8888FF")
                                  : Qt.rgba(255, 255, 255, 0.06)
                    
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "space_bar"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: ShellService.floatingTaskbar ? (root.theme ? root.theme.accentPrimary : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                        
                        Text {
                            text: "Floating Dock"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: ShellService.floatingTaskbar ? Font.Bold : Font.Normal
                            color: ShellService.floatingTaskbar ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                    }
                    
                    MouseArea {
                        id: maFloatingTb
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellService.setFloatingTaskbar(true)
                    }
                }
                
                // Docked Bottom Bar Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: !ShellService.floatingTaskbar 
                           ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.22) : Qt.rgba(0.4, 0.4, 1.0, 0.22))
                           : (maDockedTb.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(255, 255, 255, 0.02))
                    border.width: 1
                    border.color: !ShellService.floatingTaskbar 
                                  ? (root.theme ? root.theme.accentPrimary : "#8888FF")
                                  : Qt.rgba(255, 255, 255, 0.06)
                    
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "vertical_align_bottom"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: !ShellService.floatingTaskbar ? (root.theme ? root.theme.accentPrimary : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                        
                        Text {
                            text: "Docked Bar"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: !ShellService.floatingTaskbar ? Font.Bold : Font.Normal
                            color: !ShellService.floatingTaskbar ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#AAA")
                        }
                    }
                    
                    MouseArea {
                        id: maDockedTb
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellService.setFloatingTaskbar(false)
                    }
                }
            }
        }

        // Floating Bottom Margin Slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: ShellService.floatingTaskbar
            
            Text {
                text: "Floating Bottom Margin: " + ShellService.taskbarBottomMargin + "px"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "vertical_align_bottom"
                valueText: ShellService.taskbarBottomMargin + " px"
                value: (ShellService.taskbarBottomMargin / 48.0) * 100
                
                onValueChangedByUser: (val) => {
                    var margin = Math.round((val / 100.0) * 48);
                    ShellService.setTaskbarBottomMargin(margin);
                }
            }
        }

        // Floating Corner Radius Slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: ShellService.floatingTaskbar
            
            Text {
                text: "Floating Corner Radius: " + ShellService.radiusTaskbarFloating + "px"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "rounded_corner"
                valueText: ShellService.radiusTaskbarFloating + " px"
                value: ((ShellService.radiusTaskbarFloating - 8) / 28.0) * 100
                
                onValueChangedByUser: (val) => {
                    var rad = Math.round(8 + (val / 100.0) * 28);
                    ShellService.setRadiusTaskbarFloating(rad);
                }
            }
        }

        // Taskbar Width Slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Taskbar Width: " + Math.round(ShellService.taskbarWidthPercent * 100) + "%"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "width"
                valueText: Math.round(ShellService.taskbarWidthPercent * 100) + "%"
                value: ((ShellService.taskbarWidthPercent - 0.40) / 0.58) * 100
                
                onValueChangedByUser: (val) => {
                    var widthPct = 0.40 + (val / 100.0) * 0.58;
                    ShellService.setTaskbarWidthPercent(widthPct);
                }
            }
        }
    }
}
