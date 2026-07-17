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
            
            // --- System Audio Section ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 24
                
                Text {
                    text: "System Audio"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accentPrimary : "#FFF"
                }
                
                SystemVolumeCard { theme: root.theme }
                OutputDeviceCard { theme: root.theme }
                MicVolumeCard { theme: root.theme }
                InputDeviceCard { theme: root.theme }
            }
            
            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(255, 255, 255, 0.1)
            }
            
            // --- Cider Integration Section ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 24
                
                Text {
                    text: "Cider Integration"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accentPrimary : "#FFF"
                }
                
                CiderVolumeCard { theme: root.theme }
                AudioLabCard { theme: root.theme }
            }
            
            Item { Layout.preferredHeight: 40 } // Bottom padding
        }
    }
    
    Component.onCompleted: {
        VolumeService.scanSinks();
    }
}
