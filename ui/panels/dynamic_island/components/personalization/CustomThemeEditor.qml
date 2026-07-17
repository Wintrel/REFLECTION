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

    // Accent Colors
    Text {
        text: "Accent Color"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 6
        rowSpacing: 16
        columnSpacing: 16
        
        Repeater {
            model: [
                "#FF3366", // Red/Pink
                "#FF6B33", // Orange
                "#FFD633", // Yellow
                "#33FF55", // Green
                "#00FFAA", // Teal
                "#3399FF", // Blue
                "#6633FF", // Purple
                "#FF33FF", // Magenta
                "#8C8C9E", // Grey/Silver
                "#FFFFFF"  // White
            ]
            
            delegate: Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: modelData
                
                property bool isSelected: ThemeService.accentPrimary.toString().toUpperCase() === modelData.toUpperCase()
                
                border.width: isSelected ? 3 : 0
                border.color: "#FFF"
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var baseC = Qt.color(modelData);
                        ThemeService.updateCustomColor("accentPrimary", modelData);
                        ThemeService.updateCustomColor("colorSystemShimmer", Qt.lighter(baseC, 1.2));
                        
                        // Tint other accents by blending the accent with black/dark gray
                        ThemeService.updateCustomColor("colorNotification", Qt.tint("#2A2A30", Qt.rgba(baseC.r, baseC.g, baseC.b, 0.2)));
                        ThemeService.updateCustomColor("colorMusic", Qt.tint("#3A3A40", Qt.rgba(baseC.r, baseC.g, baseC.b, 0.3)));
                        ThemeService.updateCustomColor("accentWorkspace", Qt.tint("#15151A", Qt.rgba(baseC.r, baseC.g, baseC.b, 0.15)));
                    }
                }
            }
        }
    }
    
    // Background Mode
    Text {
        text: "Background Style"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.topMargin: 8
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
