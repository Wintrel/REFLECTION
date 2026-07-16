import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/media" as Media

Item {
    id: root
    
    property var theme: null
    property var mprisPlayer: null
    property bool isDetailView: false
    
    onVisibleChanged: {
        if (visible) {
            Media.CiderService.fetchPlaylists();
            isDetailView = false;
        }
    }

    // Grid View for Playlists
    GridView {
        id: grid
        anchors.fill: parent
        anchors.margins: 16
        cellWidth: 160
        cellHeight: 200
        clip: true
        visible: !root.isDetailView
        
        model: Media.CiderService.userPlaylists
        
        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight
            
            Rectangle {
                id: card
                anchors.fill: parent
                anchors.margins: 10
                radius: 12
                color: ma.containsMouse ? Qt.rgba(255,255,255,0.1) : "transparent"
                border.color: ma.containsMouse ? Qt.rgba(255,255,255,0.2) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                
                scale: ma.pressed ? 0.95 : (ma.containsMouse ? 1.02 : 1)
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    Rectangle {
                        id: coverContainer
                        width: parent.width
                        height: parent.width
                        radius: 8
                        color: "#313244"
                        
                        Image {
                            id: coverImage
                            anchors.fill: parent
                            source: modelData.artwork || ""
                            fillMode: Image.PreserveAspectCrop
                            visible: source != ""
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle { width: coverContainer.width; height: coverContainer.height; radius: 8 }
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "queue_music"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 32
                            color: root.theme ? root.theme.textSub : "#A6ADC8"
                            visible: !coverImage.visible
                        }
                    }
                    
                    Text {
                        width: parent.width
                        text: modelData.name || "Unknown Playlist"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        font.bold: true
                        color: root.theme ? root.theme.textMain : "#FFF"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Media.CiderService.currentPlaylist = modelData;
                        Media.CiderService.currentPlaylistTracks = [];
                        Media.CiderService.fetchPlaylistTracks(modelData.href);
                        root.isDetailView = true;
                    }
                }
            }
        }
    }

    // Detail View
    Item {
        id: detailView
        anchors.fill: parent
        visible: root.isDetailView
        
        Column {
            anchors.fill: parent
            
            // Header
            Item {
                width: parent.width
                height: 140
                
                // Back Button
                Rectangle {
                    x: 16
                    y: 16
                    width: 36
                    height: 36
                    radius: 18
                    color: backMa.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                    border.color: backMa.containsMouse ? Qt.rgba(255, 255, 255, 0.2) : "transparent"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "arrow_back"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    
                    MouseArea {
                        id: backMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isDetailView = false
                    }
                }
                
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16
                    
                    Rectangle {
                        width: 100
                        height: 100
                        radius: 8
                        color: "#313244"
                        
                        Image {
                            anchors.fill: parent
                            source: Media.CiderService.currentPlaylist ? (Media.CiderService.currentPlaylist.artwork || "") : ""
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle { width: 100; height: 100; radius: 8 }
                            }
                        }
                    }
                    
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        
                        Text {
                            text: Media.CiderService.currentPlaylist ? (Media.CiderService.currentPlaylist.name || "Unknown") : ""
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 24
                            font.bold: true
                            color: root.theme ? root.theme.textMain : "#FFF"
                        }
                        
                        Rectangle {
                            width: 120
                            height: 36
                            radius: 18
                            color: playAllMa.containsMouse ? (root.theme ? root.theme.accentPrimary : "#CBA6F7") : Qt.rgba(255, 255, 255, 0.1)
                            border.color: Qt.rgba(255, 255, 255, 0.2)
                            border.width: playAllMa.containsMouse ? 0 : 1
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                Text {
                                    text: "play_arrow"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 20
                                    color: playAllMa.containsMouse ? "#11111b" : (root.theme ? root.theme.textMain : "#FFF")
                                }
                                Text {
                                    text: "Play All"
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: playAllMa.containsMouse ? "#11111b" : (root.theme ? root.theme.textMain : "#FFF")
                                }
                            }
                            
                            MouseArea {
                                id: playAllMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (Media.CiderService.currentPlaylist) {
                                        Media.CiderService.playPlaylist(Media.CiderService.currentPlaylist.type, Media.CiderService.currentPlaylist.id);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Tracks List
            ListView {
                id: trackList
                width: parent.width
                height: parent.height - 140
                clip: true
                model: Media.CiderService.currentPlaylistTracks
                
                delegate: Item {
                    width: trackList.width
                    height: 64
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        color: itemMa.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent"
                        radius: 8
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    
                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 12
                        spacing: 16
                        
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 6
                            color: "#313244"
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Image {
                                anchors.fill: parent
                                source: modelData.artwork || ""
                                fillMode: Image.PreserveAspectCrop
                                visible: source != ""
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle { width: 44; height: 44; radius: 6 }
                                }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "music_note"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 18
                                color: root.theme ? root.theme.textSub : "#A6ADC8"
                                visible: modelData.artwork == ""
                            }
                        }
                        
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 44 - 16 - 100
                            
                            Row {
                                spacing: 8
                                Text {
                                    text: modelData.name || "Unknown Track"
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                    elide: Text.ElideRight
                                }
                                
                                Rectangle {
                                    visible: (modelData.contentRating === "explicit")
                                    width: 14; height: 14
                                    radius: 3
                                    color: Qt.rgba(255,255,255,0.2)
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        anchors.centerIn: parent
                                        text: "E"
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: "#FFF"
                                    }
                                }
                            }
                            
                            Text {
                                text: (modelData.artistName || "Unknown Artist") + (modelData.albumName ? " • " + modelData.albumName : "")
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 13
                                color: root.theme ? root.theme.textSub : "#A6ADC8"
                                width: parent.width
                                elide: Text.ElideRight
                            }
                        }
                    }
                    
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 16
                        spacing: 16
                        
                        Text {
                            text: {
                                var dur = modelData.durationInMillis || 0;
                                if (dur === 0) return "--:--";
                                var totalSecs = Math.floor(dur / 1000);
                                var mins = Math.floor(totalSecs / 60);
                                var secs = totalSecs % 60;
                                return mins + ":" + (secs < 10 ? "0" : "") + secs;
                            }
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            color: root.theme ? root.theme.textSub : "#A6ADC8"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    MouseArea {
                        id: itemMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Media.CiderService.playTrack(modelData.id);
                        }
                    }
                }
            }
        }
    }
}
