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
    
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 32
            
            // --- Appearance Section ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 24
                
                Text {
                    text: "Aesthetics"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accentPrimary : "#FFF"
                }
                
                ThemeCard { theme: root.theme }
                
                CustomThemeEditor { theme: root.theme }
                
                WallpaperCard { theme: root.theme }
                
                GeometryCard { theme: root.theme }
            }
            
            Item { Layout.preferredHeight: 40 } // Bottom padding
        }
    }
}
