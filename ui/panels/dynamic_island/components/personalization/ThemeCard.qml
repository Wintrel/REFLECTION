import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/system"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8
    
    Text {
        text: "Shell Theme"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: root.theme ? root.theme.textMain : "#FFF"
    }
    
    Text {
        text: "Select a color palette for your desktop shell. Custom themes can be created in the future."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }
    
    // Grid of themes
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 12
        columnSpacing: 12
        
        Repeater {
            model: ThemeService.themes
            
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 8
                
                property bool isCurrent: modelData.name === ThemeService.currentTheme
                
                color: "transparent"
                border.width: isCurrent ? 2 : (maTheme.containsMouse ? 1 : 0)
                border.color: isCurrent ? modelData.accentPrimary : (maTheme.containsMouse ? Qt.rgba(255, 255, 255, 0.2) : "transparent")
                
                Behavior on border.width { NumberAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    // Swatch
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: modelData.bgInner
                        border.width: 2
                        border.color: modelData.accentPrimary
                        
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: modelData.colorNotification
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: modelData.name
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        font.weight: isCurrent ? Font.Bold : Font.Normal
                        color: isCurrent ? modelData.accentPrimary : (root.theme ? root.theme.textMain : "#FFF")
                    }
                    
                    // Active checkmark
                    Text {
                        visible: parent.parent.isCurrent
                        text: "check_circle"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: modelData.accentPrimary
                    }
                }
                
                MouseArea {
                    id: maTheme
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ThemeService.applyTheme(modelData.name)
                    }
                }
            }
        }
    }
}
