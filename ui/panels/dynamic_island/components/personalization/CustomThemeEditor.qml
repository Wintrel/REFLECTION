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
    
    visible: ThemeService.currentTheme === "Custom"
    
    property string activeEditProperty: "accentPrimary"
    
    // Convert hex to HSL (simplified approximation for UI init)
    function hexToHsl(hex) {
        var r = parseInt(hex.substring(1, 3), 16) / 255;
        var g = parseInt(hex.substring(3, 5), 16) / 255;
        var b = parseInt(hex.substring(5, 7), 16) / 255;
        
        var max = Math.max(r, g, b), min = Math.min(r, g, b);
        var h, s, l = (max + min) / 2;
        
        if (max === min) {
            h = s = 0; // achromatic
        } else {
            var d = max - min;
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
            switch (max) {
                case r: h = (g - b) / d + (g < b ? 6 : 0); break;
                case g: h = (b - r) / d + 2; break;
                case b: h = (r - g) / d + 4; break;
            }
            h /= 6;
        }
        return {h: h*100, s: s*100, l: l*100};
    }
    
    function rgbToHex(r, g, b) {
        return "#" + (1 << 24 | Math.round(r*255) << 16 | Math.round(g*255) << 8 | Math.round(b*255)).toString(16).slice(1).toUpperCase();
    }
    
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

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: "Use Gradients"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 13
            color: root.theme ? root.theme.textMain : "#FFF"
            Layout.fillWidth: true
        }
        Rectangle {
            id: gradSwitch
            width: 44
            height: 24
            radius: 12
            color: ThemeService.useGradients ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : Qt.rgba(255,255,255,0.1)
            border.width: 1
            border.color: ThemeService.useGradients ? "transparent" : Qt.rgba(255,255,255,0.2)
            
            Behavior on color { ColorAnimation { duration: 150 } }
            
            Rectangle {
                width: 18
                height: 18
                radius: 9
                color: "#FFF"
                x: ThemeService.useGradients ? (parent.width - width - 3) : 3
                y: 3
                
                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    ThemeService.setUseGradients(!ThemeService.useGradients)
                }
            }
        }
    }


    // Property Selector
    GridLayout {
        Layout.fillWidth: true
        columns: 4
        columnSpacing: 8
        rowSpacing: 8
        
        Repeater {
            model: [
                { id: "accentPrimary", name: "Primary Accent" },
                { id: "accentSecondary", name: "Secondary Accent" },
                { id: "accentNotification", name: "Notifications" },
                { id: "accentMusic", name: "Music" },
                { id: "bgBase", name: "Base BG" },
                { id: "bgBezel", name: "Bezel BG" },
                { id: "bgInner", name: "Inner BG" },
                { id: "surfaceCard", name: "Card Surface" },
                { id: "surfaceOverlay", name: "Overlay (Hover)" },
                { id: "textMain", name: "Primary Text" },
                { id: "textSub", name: "Sub Text" },
                { id: "textMuted", name: "Muted Text" },
                { id: "colorSystemShimmer", name: "Shimmer Effect" },

                { id: "bgInnerGradientEnd", name: "BgInner Grad" },
                { id: "surfaceCardGradientEnd", name: "Card Grad" },
                { id: "accentPrimaryGradientEnd", name: "Primary Grad" },
            ]
            
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 6
                
                property bool isActive: root.activeEditProperty === modelData.id
                color: isActive ? ThemeService.accentPrimary : Qt.rgba(255, 255, 255, 0.05)
                border.width: isActive ? 0 : (maProp.containsMouse ? 1 : 0)
                border.color: Qt.rgba(255, 255, 255, 0.2)
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    font.weight: isActive ? Font.Bold : Font.Normal
                    color: isActive ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                }
                
                MouseArea {
                    id: maProp
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.activeEditProperty = modelData.id
                    }
                }
            }
        }
    }
    
    // Color Picker Area
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        radius: 12
        color: Qt.rgba(0, 0, 0, 0.2)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.1)
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 24
            
            // Preview Circle
            ColumnLayout {
                spacing: 12
                
                Rectangle {
                    width: 80
                    height: 80
                    radius: 40
                    color: ThemeService[root.activeEditProperty]
                    border.width: 2
                    border.color: Qt.rgba(255, 255, 255, 0.2)
                }
                
                Text {
                    text: ThemeService[root.activeEditProperty].toString().toUpperCase()
                    font.family: "Monospace"
                    font.pixelSize: 14
                    color: root.theme ? root.theme.textMain : "#FFF"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            // Sliders
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                
                // Hue
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "H"; color: root.theme ? root.theme.textSub : "#AAA"; font.pixelSize: 12 }
                    CC.ThickSlider {
                        id: hueSlider
                        Layout.fillWidth: true
                        theme: root.theme
                        icon: "palette"
                        value: root.hexToHsl(ThemeService[root.activeEditProperty].toString()).h
                        onValueChangedByUser: (val) => {
                            var c = Qt.hsla(val/100.0, satSlider.value/100.0, lightSlider.value/100.0, 1.0)
                            ThemeService.updateCustomColor(root.activeEditProperty, root.rgbToHex(c.r, c.g, c.b))
                        }
                    }
                }
                
                // Saturation
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "S"; color: root.theme ? root.theme.textSub : "#AAA"; font.pixelSize: 12 }
                    CC.ThickSlider {
                        id: satSlider
                        Layout.fillWidth: true
                        theme: root.theme
                        icon: "contrast"
                        value: root.hexToHsl(ThemeService[root.activeEditProperty].toString()).s
                        onValueChangedByUser: (val) => {
                            var c = Qt.hsla(hueSlider.value/100.0, val/100.0, lightSlider.value/100.0, 1.0)
                            ThemeService.updateCustomColor(root.activeEditProperty, root.rgbToHex(c.r, c.g, c.b))
                        }
                    }
                }
                
                // Lightness
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "L"; color: root.theme ? root.theme.textSub : "#AAA"; font.pixelSize: 12 }
                    CC.ThickSlider {
                        id: lightSlider
                        Layout.fillWidth: true
                        theme: root.theme
                        icon: "lightbulb"
                        value: root.hexToHsl(ThemeService[root.activeEditProperty].toString()).l
                        onValueChangedByUser: (val) => {
                            var c = Qt.hsla(hueSlider.value/100.0, satSlider.value/100.0, val/100.0, 1.0)
                            ThemeService.updateCustomColor(root.activeEditProperty, root.rgbToHex(c.r, c.g, c.b))
                        }
                    }
                }
            }
        }
    }
}
