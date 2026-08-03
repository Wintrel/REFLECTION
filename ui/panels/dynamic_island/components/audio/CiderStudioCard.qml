import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../control_center/components" as CC
import "../../../../../core/services/media"

Rectangle {
    id: root

    property var theme
    readonly property color musicAccent: theme ? theme.accentMusic : "#7257d9"
    readonly property bool hasTrack: CiderService.trackTitle !== ""

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignTop
    implicitHeight: studioColumn.implicitHeight + 40
    radius: 20
    color: theme ? Qt.rgba(theme.surfaceCard.r, theme.surfaceCard.g, theme.surfaceCard.b, 0.78) : Qt.rgba(0.08, 0.08, 0.10, 0.78)
    border.width: 1
    border.color: Qt.rgba(musicAccent.r, musicAccent.g, musicAccent.b, 0.25)
    clip: true

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 132
        color: Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.055)
    }

    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 34
        anchors.topMargin: 22
        spacing: 7
        opacity: 0.16

        Repeater {
            model: [22, 38, 29, 54, 42, 64, 33, 49, 25]
            Rectangle {
                width: 3
                height: modelData
                radius: 2
                color: root.musicAccent
            }
        }
    }

    ColumnLayout {
        id: studioColumn
        anchors.fill: parent
        anchors.margins: 20
        spacing: 18

        RowLayout {
            Layout.fillWidth: true
            spacing: 18

            Rectangle {
                Layout.preferredWidth: 104
                Layout.preferredHeight: 104
                radius: 16
                color: Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.14)
                border.width: 1
                border.color: Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.28)

                Image {
                    id: artwork
                    anchors.fill: parent
                    source: root.hasTrack ? CiderService.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: source.toString() !== ""
                    layer.enabled: visible
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: artwork.width
                            height: artwork.height
                            radius: 16
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: !artwork.visible
                    text: "music_note"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 38
                    color: root.musicAccent
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "CIDER STUDIO"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1.3
                        color: root.musicAccent
                    }

                    Rectangle {
                        Layout.preferredWidth: statusText.implicitWidth + 16
                        Layout.preferredHeight: 22
                        radius: 11
                        color: root.hasTrack ? Qt.rgba(0.35, 0.85, 0.65, 0.10) : Qt.rgba(255, 255, 255, 0.055)

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: root.hasTrack ? (CiderService.isPlaying ? "PLAYING" : "PAUSED") : "IDLE"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            font.letterSpacing: 0.7
                            color: root.hasTrack ? "#62D6A8" : (root.theme ? root.theme.textSub : "#999")
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.hasTrack ? CiderService.trackTitle : "Ready for playback"
                    elide: Text.ElideRight
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.hasTrack ? (CiderService.trackArtist || "Unknown artist") : "Start a track in Cider to bring the studio to life"
                    elide: Text.ElideRight
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#999"
                }
            }

            Rectangle {
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                Layout.alignment: Qt.AlignVCenter
                radius: 14
                color: playMouse.containsMouse ? Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.24) : Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.13)
                border.width: 1
                border.color: Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.28)
                opacity: root.hasTrack ? 1 : 0.45

                Text {
                    anchors.centerIn: parent
                    text: CiderService.isPlaying ? "pause" : "play_arrow"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 25
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.hasTrack
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: CiderService.togglePlaying()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(255, 255, 255, 0.06)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Playback volume"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Cider master output"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: root.theme ? root.theme.textSub : "#999"
                }
            }

            CC.ThickSlider {
                Layout.fillWidth: true
                theme: root.theme
                icon: CiderService.volume <= 0.01 ? "volume_off" : "volume_up"
                property real localVolume: CiderService.volume * 100
                value: localVolume
                onValueChangedByUser: val => {
                    localVolume = val
                    CiderService.setVolume(val / 100)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Audio processing"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: root.theme ? root.theme.textMain : "#FFF"
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "Powered by Cider's audio engine"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 10
                color: root.theme ? root.theme.textSub : "#999"
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width >= 880 ? 3 : 1
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: [
                    { key: "atmos", icon: "spatial_audio", title: "Spatial Audio", detail: "Dolby Atmos processing" },
                    { key: "crossfade", icon: "graphic_eq", title: "Spectral Crossfade", detail: "Blend transitions between tracks" },
                    { key: "normalization", icon: "equalizer", title: "Smart Volume", detail: "Keep loudness consistent" }
                ]

                delegate: Rectangle {
                    id: dspTile
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 82
                    radius: 13
                    color: enabledState ? Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.105) : (dspMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.022))
                    border.width: 1
                    border.color: enabledState ? Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.42) : Qt.rgba(255, 255, 255, 0.06)

                    readonly property bool enabledState: modelData.key === "atmos" ? CiderService.atmosEnabled
                                                        : modelData.key === "crossfade" ? CiderService.crossfadeEnabled
                                                        : CiderService.normalizationEnabled

                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 13
                        spacing: 11

                        Rectangle {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38
                            radius: 11
                            color: dspTile.enabledState ? Qt.rgba(root.musicAccent.r, root.musicAccent.g, root.musicAccent.b, 0.22) : Qt.rgba(255, 255, 255, 0.045)
                            Text {
                                anchors.centerIn: parent
                                text: dspTile.modelData.icon
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 20
                                color: dspTile.enabledState ? root.musicAccent : (root.theme ? root.theme.textSub : "#999")
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: dspTile.modelData.title
                                elide: Text.ElideRight
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: root.theme ? root.theme.textMain : "#FFF"
                            }
                            Text {
                                Layout.fillWidth: true
                                text: dspTile.modelData.detail
                                elide: Text.ElideRight
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 9
                                color: root.theme ? root.theme.textSub : "#999"
                            }
                        }

                        Text {
                            text: dspTile.enabledState ? "toggle_on" : "toggle_off"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 30
                            color: dspTile.enabledState ? root.musicAccent : (root.theme ? root.theme.textSub : "#777")
                        }
                    }

                    MouseArea {
                        id: dspMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (dspTile.modelData.key === "atmos")
                                CiderService.toggleAtmos(!dspTile.enabledState)
                            else if (dspTile.modelData.key === "crossfade")
                                CiderService.toggleCrossfade(!dspTile.enabledState)
                            else
                                CiderService.toggleNormalization(!dspTile.enabledState)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: CiderService.fetchConfig()
}
