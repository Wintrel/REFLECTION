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
        text: "Edge Lighting"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 18
        font.weight: Font.Bold
        color: root.theme ? root.theme.accentPrimary : "#FFF"
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        
        Text {
            text: "Glow Intensity: " + Math.round(ThemeService.edgeLightingIntensity * 100) + "%"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            color: root.theme ? root.theme.textMain : "#FFF"
        }
        
        CC.ThickSlider {
            Layout.fillWidth: true
            theme: root.theme
            icon: "lightbulb"
            
            property real internalValue: ThemeService.edgeLightingIntensity * 100
            value: internalValue
            
            onValueChangedByUser: (val) => {
                internalValue = val;
                var intensity = val / 100.0;
                ThemeService.updateEdgeLighting(intensity);
            }
        }
        
        Text {
            visible: ThemeService.edgeLightingIntensity >= 0.8
            text: ThemeService.edgeLightingIntensity >= 0.95 ? "Sunglasses recommeneded. May the sun be with you." : "I hope you know what you're doing, because your retinas are about to burn."
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: "#FF3366" // Aggressive red/pink
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            Layout.topMargin: 4
        }
    }
}
