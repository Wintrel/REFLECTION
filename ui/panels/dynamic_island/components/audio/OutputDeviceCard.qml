import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../../../core/services/system"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8
    
    Text {
        text: "Output Device"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: root.theme ? root.theme.textMain : "#FFF"
    }
    
    Text {
        text: "Select the primary audio output device."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Repeater {
            model: VolumeService.audioSinks
            delegate: Rectangle {
                Layout.fillWidth: true
                implicitHeight: 48
                radius: 8
                
                color: model.isDefault ? (root.theme ? root.theme.accentPrimary : "#444") : (maSink.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                border.width: 1
                border.color: model.isDefault ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maSink.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16
                    
                    Text {
                        text: "speaker"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: model.isDefault ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: model.name
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: model.isDefault ? Font.DemiBold : Font.Medium
                        color: model.isDefault ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        visible: model.isDefault
                        text: "check_circle"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: "#000"
                    }
                }
                
                MouseArea {
                    id: maSink
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        VolumeService.setDefaultSink(model.sinkId);
                    }
                }
            }
        }
    }
}
