import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../../../core/state" as State
import "../../../../core/services/system"
import "."

ControlCenterMenu {
    id: audioMenu
    
    property var ccRoot
    
    anchors.fill: parent
    anchors.margins: 24
    theme: ccRoot ? ccRoot.theme : null
    title: "Audio Output"
    opacity: (ccRoot && ccRoot.viewState === "audio") ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
    onBackClicked: {
        if (ccRoot) ccRoot.viewState = "main"
    }
    
    model: VolumeService.audioSinks
    delegate: Item {
        width: parent.width
        height: 52

        Item {
            anchors.fill: parent
            scale: maAudio.pressed ? 0.97 : 1
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: maAudio.pressed ? (audioMenu.theme ? audioMenu.theme.accentPrimary : "#ff9900")
                     : (model.isDefault ? (audioMenu.theme ? audioMenu.theme.accentWorkspace : "#5611f8")
                                        : Qt.rgba(255,255,255,0.03))
                
                border.width: 1
                border.color: (maAudio.pressed || model.isDefault) ? "transparent"
                            : (maAudio.containsMouse ? (audioMenu.theme ? audioMenu.theme.accentPrimary : "#ff9900")
                                                     : "transparent")
                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on border.color { ColorAnimation { duration: 250 } }
            }

            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: model.isDefault ? Qt.rgba(255,255,255,0.1) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: model.name.toLowerCase().includes("head") ? "headphones" : "speaker"
                        font.family: audioMenu.theme ? audioMenu.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: audioMenu.theme ? audioMenu.theme.textMain : "#FFF"
                        anchors.centerIn: parent
                    }
                }

                Text {
                    text: model.name
                    font.family: audioMenu.theme ? audioMenu.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    color: audioMenu.theme ? audioMenu.theme.textMain : "#FFF"
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 52
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: maAudio
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                VolumeService.setDefaultSink(model.sinkId)
            }
        }
    }
}
