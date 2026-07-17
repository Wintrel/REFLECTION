import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 16
    
    // Only visible if current theme is Custom
    visible: ThemeService.currentTheme === "Custom"
    
    // Property Selector State
    property string activeEditProperty: "accentPrimary"
    
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(255, 255, 255, 0.1)
    }

    Text {
        text: "Custom Theme Editor"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: root.theme ? root.theme.textMain : "#FFF"
    }

    // Component Target Selector
    Text {
        text: "Select Component to Tint"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        
        Repeater {
            model: [
                { id: "accentPrimary", name: "Global Accent" },
                { id: "colorNotification", name: "Notifications" },
                { id: "colorMusic", name: "Music Player" },
                { id: "accentWorkspace", name: "Workspaces" }
            ]
            
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 8
                color: root.activeEditProperty === modelData.id ? ThemeService.accentPrimary : Qt.rgba(255, 255, 255, 0.05)
                border.width: root.activeEditProperty === modelData.id ? 0 : (maTab.containsMouse ? 1 : 0)
                border.color: Qt.rgba(255, 255, 255, 0.2)
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    font.weight: root.activeEditProperty === modelData.id ? Font.Bold : Font.Normal
                    color: root.activeEditProperty === modelData.id ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                }
                
                MouseArea {
                    id: maTab
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeEditProperty = modelData.id
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 8
        rowSpacing: 12
        columnSpacing: 12
        Layout.topMargin: 8
        
        Repeater {
            model: [
                // Vibrant Accents
                "#FF3366", "#FF6B33", "#FFD633", "#33FF55", 
                "#00FFAA", "#3399FF", "#6633FF", "#FF33FF", 
                "#8C8C9E", "#FFFFFF",
                // Muted/Dark Background Accents
                "#2A2A30", "#3A3A40", "#15151A", "#1C1C24",
                "#3F3F4A", "#000000"
            ]
            
            delegate: Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: modelData
                
                property bool isSelected: ThemeService[root.activeEditProperty].toString().toUpperCase() === modelData.toUpperCase()
                
                border.width: isSelected ? 3 : 0
                border.color: "#FFF"
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ThemeService.updateCustomColor(root.activeEditProperty, modelData);
                        // Only auto-update shimmer when global accent is changed. 
                        // We NO LONGER auto-tint other components, granting true granular control!
                        if (root.activeEditProperty === "accentPrimary") {
                            ThemeService.updateCustomColor("colorSystemShimmer", Qt.lighter(modelData, 1.2));
                        }
                    }
                }
            }
        }
    }
    
    // Background Mode
    Text {
        text: "Global Background Style"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.topMargin: 12
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 12
        
        Repeater {
            model: [
                { name: "Pitch Black", bgBezel: "#000000", bgInner: "#000000", bgBase: "#000000", textMain: "#D4D4D8", textSub: "#82828C" },
                { name: "Deep Gray", bgBezel: "#000000", bgInner: "#0A0A0F", bgBase: "#050505", textMain: "#E0F0F0", textSub: "#508080" },
                { name: "Slate", bgBezel: "#050505", bgInner: "#15151A", bgBase: "#101015", textMain: "#FFFFFF", textSub: "#AAAAAA" }
            ]
            
            delegate: Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                radius: 8
                color: modelData.bgInner
                border.width: ThemeService.bgInner.toString().toUpperCase() === modelData.bgInner.toUpperCase() ? 2 : 1
                border.color: ThemeService.bgInner.toString().toUpperCase() === modelData.bgInner.toUpperCase() ? ThemeService.accentPrimary : Qt.rgba(255, 255, 255, 0.1)
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: ThemeService.bgInner.toString().toUpperCase() === modelData.bgInner.toUpperCase() ? ThemeService.accentPrimary : (root.theme ? root.theme.textMain : "#FFF")
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ThemeService.updateCustomColor("bgBezel", modelData.bgBezel);
                        ThemeService.updateCustomColor("bgInner", modelData.bgInner);
                        ThemeService.updateCustomColor("bgBase", modelData.bgBase);
                        ThemeService.updateCustomColor("textMain", modelData.textMain);
                        ThemeService.updateCustomColor("textSub", modelData.textSub);
                    }
                }
            }
        }
    }
}
