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
        text: "Geometry & Motion"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 18
        font.weight: Font.Bold
        color: root.theme ? root.theme.accentPrimary : "#FFF"
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 24
        
        // Corner Roundness
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Corner Roundness: " + Math.round(ThemeService.radiusIsland) + "px"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 14
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            
            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: "rounded_corner"
                
                property real internalValue: (ThemeService.radiusIsland / 24.0) * 100
                value: internalValue
                
                onValueChangedByUser: (val) => {
                    internalValue = val;
                    var rad = Math.round((val / 100.0) * 24);
                    ThemeService.updateGeometry(rad, -1);
                }
            }
        }
        
        // Animation Speed
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
                
                property real internalValue: (ThemeService.animDuration / 1500.0) * 100
                value: internalValue
                
                onValueChangedByUser: (val) => {
                    internalValue = val;
                    var dur = Math.round((val / 100.0) * 1500);
                    ThemeService.updateGeometry(-1, dur);
                }
            }
        }
    }
}
