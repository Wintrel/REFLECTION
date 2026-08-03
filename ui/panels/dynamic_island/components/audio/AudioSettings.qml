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

    component AudioSurface: Rectangle {
        default property alias content: surfaceColumn.data
        property string icon: ""
        property string title: ""
        property string subtitle: ""

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        implicitHeight: surfaceColumn.implicitHeight + 40
        radius: 18
        color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.70) : Qt.rgba(0.08, 0.08, 0.10, 0.70)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.06)

        ColumnLayout {
            id: surfaceColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 10
                    color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.13) : Qt.rgba(0.4, 0.4, 1, 0.13)
                    Text {
                        anchors.centerIn: parent
                        text: parent.parent.parent.parent.icon
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: root.theme ? root.theme.accentPrimary : "#8888DD"
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: parent.parent.parent.parent.title
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    Text {
                        text: parent.parent.parent.parent.subtitle
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                }
            }
        }
    }
    
    Flickable {
        id: audioFlickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: colLayout.implicitHeight
        clip: true
        
        flickDeceleration: 1000
        maximumFlickVelocity: 4000
        boundsBehavior: Flickable.DragAndOvershootBounds
        
        Behavior on contentY {
            enabled: !audioFlickable.dragging && !audioFlickable.flicking
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        
        ColumnLayout {
            id: colLayout
            width: parent.width
            spacing: 16

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: 14
                color: Qt.rgba(255, 255, 255, 0.02)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.055)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 10
                    Text {
                        text: "graphic_eq"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 19
                        color: root.theme ? root.theme.accentPrimary : "#8888DD"
                    }
                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "PipeWire audio"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: root.theme ? root.theme.textMain : "#FFF"
                        }
                        Text {
                            text: VolumeService.audioSinks.count + " outputs  ·  " + VolumeService.audioSources.count + " inputs"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 26
                        radius: 13
                        color: Qt.rgba(0.35, 0.85, 0.65, 0.09)
                        Text {
                            anchors.centerIn: parent
                            text: "ACTIVE"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 8
                            font.letterSpacing: 0.8
                            font.weight: Font.Bold
                            color: "#62D6A8"
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 820 ? 2 : 1
                columnSpacing: 16
                rowSpacing: 16

                AudioSurface {
                    icon: "speaker"
                    title: "Output"
                    subtitle: "Speakers, headphones and system playback"
                    SystemVolumeCard { theme: root.theme }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255, 255, 255, 0.05) }
                    OutputDeviceCard { theme: root.theme }
                }

                AudioSurface {
                    icon: "mic"
                    title: "Input"
                    subtitle: "Microphones and recording sources"
                    MicVolumeCard { theme: root.theme }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255, 255, 255, 0.05) }
                    InputDeviceCard { theme: root.theme }
                }
            }

            Item { Layout.preferredHeight: 16 }
        }
    }
    
    Component.onCompleted: {
        VolumeService.scanSinks();
    }
}
