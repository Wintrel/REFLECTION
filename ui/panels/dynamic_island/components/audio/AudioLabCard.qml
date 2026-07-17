import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../../../core/services/media"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8
    
    Text {
        text: "Audio Lab (Advanced)"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: root.theme ? root.theme.textMain : "#FFF"
    }
    
    Text {
        text: "Configure advanced DSP features and audio routing via Cider's internal audio engine."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        
        Repeater {
            model: [
                { name: "crossfade", label: "Spectral Crossfading", desc: "Seamlessly blend tracks together at the end of playback", icon: "graphic_eq", def: false },
                { name: "normalize", label: "Smart Volume", desc: "Ensure consistent playback levels across all tracks using LUFS", icon: "equalizer", def: true }
            ]
            delegate: Rectangle {
                Layout.fillWidth: true
                implicitHeight: 64
                radius: 8
                
                property bool isEnabled: {
                    if (modelData.name === "crossfade") return CiderService.crossfadeEnabled;
                    if (modelData.name === "normalize") return CiderService.normalizationEnabled;
                    return false;
                }
                
                color: isEnabled ? Qt.rgba(255, 255, 255, 0.04) : (maCard.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : Qt.rgba(255, 255, 255, 0.015))
                border.width: 1
                border.color: isEnabled ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maCard.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04))
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                scale: maCard.containsMouse ? 1.01 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                
                MouseArea {
                    id: maCard
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.name === "crossfade") CiderService.toggleCrossfade(!parent.isEnabled);
                        if (modelData.name === "normalize") CiderService.toggleNormalization(!parent.isEnabled);
                    }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16
                    
                    Text {
                        text: modelData.icon
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 22
                        color: isEnabled ? (root.theme ? root.theme.accentPrimary : "#AAA") : (root.theme ? root.theme.textSub : "#888")
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.label
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: root.theme ? root.theme.textMain : "#FFF"
                        }
                        Text {
                            text: modelData.desc
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: root.theme ? root.theme.textSub : "#888"
                            elide: Text.ElideRight
                        }
                    }
                    
                    Text {
                        text: isEnabled ? "toggle_on" : "toggle_off"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 32
                        color: isEnabled ? (root.theme ? root.theme.accentPrimary : "#4ADE80") : (root.theme ? root.theme.textSub : "#888")
                    }
                }
            }
        }
    }
}
