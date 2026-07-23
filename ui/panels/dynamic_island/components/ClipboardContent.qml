import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../core/services/system"
import "../../../../core/state" as State
import "../../../components" as Components

Item {
    id: root
    
    property int islandState
    property var theme
    property int islandClipboardW
    property int islandClipboardH
    
    visible: opacity > 0
    opacity: islandState === State.IslandState.clipboard ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo } }
    
    width: islandClipboardW
    height: islandClipboardH
    
    anchors.centerIn: parent
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Clipboard History"
                color: theme.textMain
                font.family: theme.fontMain
                font.pixelSize: 20
                font.weight: Font.Bold
                Layout.fillWidth: true
            }
            

            Rectangle {
                width: 30; height: 30; radius: 15
                color: wipeMa.containsMouse ? Qt.rgba(255,0,0,0.2) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                Text { anchors.centerIn: parent; text: "delete_sweep"; font.family: theme.fontIcon; font.pixelSize: 18; color: theme.textMain }
                MouseArea {
                    id: wipeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "cliphist wipe"]; onExited: { ClipboardService.refresh(); destroy() } }', root);
                        p.running = true;
                    }
                }
            }
        }
        
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            
            model: ClipboardService.items
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 60
                radius: 8
                color: ma.containsMouse ? Qt.rgba(255,255,255,0.1) : Qt.rgba(255,255,255,0.05)
                Behavior on color { ColorAnimation { duration: 150 } }
                
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    anchors.rightMargin: 40 // Leave space for delete button
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        ClipboardService.copyItem(model.clipId);
                    }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12
                    
                    Text {
                        text: model.isImage ? "image" : "content_copy"
                        font.family: theme.fontIcon
                        color: theme.textSub
                        font.pixelSize: 18
                    }
                    
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        Text {
                            visible: !model.isImage
                            anchors.fill: parent
                            text: model.clipText
                            color: theme.textMain
                            font.family: theme.fontMain
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        Image {
                            visible: model.isImage
                            anchors.fill: parent
                            source: model.imagePath
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignLeft
                        }
                    }
                    
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: closeMa.containsMouse ? Qt.rgba(255,0,0,0.2) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text { anchors.centerIn: parent; text: "close"; font.family: theme.fontIcon; font.pixelSize: 16; color: theme.textSub }
                        MouseArea {
                            id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: ClipboardService.deleteItem(model.clipId)
                        }
                    }
                }
            }
            
            Text {
                visible: listView.count === 0
                anchors.centerIn: parent
                text: "Clipboard is empty"
                color: theme.textSub
                font.family: theme.fontMain
                font.pixelSize: 16
            }
        }
    }
}
