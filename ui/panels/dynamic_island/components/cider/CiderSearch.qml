import QtQuick
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    
    property var mprisPlayer: null
    property var theme: null
    property int searchMode: 0 // 0: All, 1: Artist, 2: Album
    
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 12
    clip: true
    
    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8
        
        Rectangle {
            width: parent.width
            height: 40
            color: Qt.rgba(255, 255, 255, 0.05)
            radius: 8
            
            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "search"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: searchInput.activeFocus ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                }
                
                TextInput {
                    id: searchInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 30 - 40 - 24
                    color: root.theme ? root.theme.textMain : "#FFF"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 15
                    selectByMouse: true
                    selectionColor: Qt.rgba(255,255,255,0.2)
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Search Apple Music..."
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        font: searchInput.font
                        visible: searchInput.text === "" && !searchInput.activeFocus
                    }
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.mprisPlayer && typeof root.mprisPlayer.search === 'function') {
                                let q = searchInput.text;
                                if (root.searchMode === 1) q = "artist:" + q;
                                else if (root.searchMode === 2) q = "album:" + q;
                                root.mprisPlayer.search(q);
                            }
                            event.accepted = true;
                        }
                    }
                }
                
                Rectangle {
                    width: 40
                    height: 28
                    radius: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: searchBtnMa.containsMouse ? (root.theme ? root.theme.accentPrimary : "#CBA6F7") : Qt.rgba(255,255,255,0.1)
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "arrow_forward"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 16
                        color: searchBtnMa.containsMouse ? "#11111b" : (root.theme ? root.theme.textMain : "#FFF")
                    }
                    
                    MouseArea {
                        id: searchBtnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && typeof root.mprisPlayer.search === 'function') {
                                let q = searchInput.text;
                                if (root.searchMode === 1) q = "artist:" + q;
                                else if (root.searchMode === 2) q = "album:" + q;
                                root.mprisPlayer.search(q);
                            }
                        }
                    }
                }
            }
        }
        
        Row {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter
            
            Repeater {
                model: ["Any", "Artist", "Album"]
                delegate: Rectangle {
                    width: filterText.width + 24
                    height: 24
                    radius: 12
                    color: root.searchMode === index ? (root.theme ? root.theme.accentPrimary : "#CBA6F7") : Qt.rgba(255, 255, 255, 0.05)
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        id: filterText
                        anchors.centerIn: parent
                        text: modelData
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        font.bold: root.searchMode === index
                        color: root.searchMode === index ? "#11111b" : (root.theme ? root.theme.textMain : "#FFF")
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.searchMode = index
                    }
                }
            }
        }
        
        ListView {
            id: searchList
            width: parent.width
            height: parent.height - 40 - 24 - 16 // searchbar - chips - spacing
            spacing: 8
            clip: true
            model: root.mprisPlayer ? root.mprisPlayer.searchResults : []
            
            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: root.theme ? root.theme.textSub : "#888"
                    opacity: 0.5
                }
            }
            
            delegate: Item {
                width: searchList.width
                height: 64
                
                Rectangle {
                    anchors.fill: parent
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
                            
                            Row {
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter
                                Repeater {
                                    model: {
                                        var traits = modelData.audioTraits || [];
                                        var displayTraits = [];
                                        if (traits.indexOf("lossless") !== -1 || traits.indexOf("hi-res-lossless") !== -1) displayTraits.push("Lossless");
                                        if (traits.indexOf("atmos") !== -1 || traits.indexOf("spatial") !== -1) displayTraits.push("Dolby Atmos");
                                        return displayTraits;
                                    }
                                    delegate: Rectangle {
                                        width: traitTxt.width + 8
                                        height: 14
                                        radius: 3
                                        color: "transparent"
                                        border.color: Qt.rgba(255,255,255,0.3)
                                        border.width: 1
                                        Text {
                                            id: traitTxt
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.pixelSize: 8
                                            font.bold: true
                                            color: Qt.rgba(255,255,255,0.7)
                                        }
                                    }
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
                        if (root.mprisPlayer && typeof root.mprisPlayer.playTrack === 'function') {
                            root.mprisPlayer.playTrack(modelData.id);
                        }
                    }
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: (root.mprisPlayer && root.mprisPlayer.isSearching) ? "Searching for songs..." : "Search for songs to play"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 16
                color: root.theme ? root.theme.textSub : "#A6ADC8"
                visible: searchList.count === 0
            }
        }
    }
}
