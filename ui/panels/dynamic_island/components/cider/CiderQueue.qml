import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    
    property var mprisPlayer: null
    property var theme: null
    
    color: Qt.rgba(0, 0, 0, 0.3)
    radius: 12
    clip: true
    
    ListView {
        id: queueList
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8
        model: root.mprisPlayer ? root.mprisPlayer.queue : []
        
        delegate: Item {
            width: queueList.width
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
                    width: parent.width - 44 - 16 - 150
                    
                    Row {
                        spacing: 8
                        Text {
                            text: modelData.title || "Unknown Track"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 15
                            font.bold: true
                            color: root.theme ? root.theme.textMain : "#FFF"
                            elide: Text.ElideRight
                        }
                        
                        Rectangle {
                            visible: modelData.isExplicit
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
                                    var traits = modelData.traits || [];
                                    var displayTraits = [];
                                    if (traits.indexOf("lossless") !== -1 || traits.indexOf("high-resolution-lossless") !== -1) displayTraits.push("Lossless");
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
                        text: (modelData.artist || "Unknown Artist") + (modelData.album ? " • " + modelData.album : "")
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
                    visible: modelData.inFavorites
                    text: "favorite"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: "#F38BA8"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: modelData.duration || "--:--"
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
                    // Potentially send playtrack command
                }
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: "Queue is empty"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 16
            color: root.theme ? root.theme.textSub : "#A6ADC8"
            visible: queueList.count === 0
        }
    }
}
