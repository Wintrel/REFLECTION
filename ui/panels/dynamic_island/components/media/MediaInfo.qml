import "../../../../../core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null

    width: childrenRect.width
    height: 60
    
    Rectangle {
        id: albumArt
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 60
        height: 60
        radius: root.theme ? root.theme.radiusIsland : 8
        color: root.theme ? root.theme.surfaceOverlay : "#313244"
        border.width: root.theme ? root.theme.islandBorderWidth : 0
        border.color: root.theme ? root.theme.accentPrimary : "transparent"
        
        property bool isVisible: root.islandState === State.IslandState.expanded
        opacity: (root.islandState === State.IslandState.expanded) ? 1 : 0
        transform: Scale {
            origin.x: 30; origin.y: 30
            xScale: (root.islandState === State.IslandState.expanded) ? 1 : 0.8
            yScale: (root.islandState === State.IslandState.expanded) ? 1 : 0.8
            Behavior on xScale { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutBack } } }
            Behavior on yScale { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutBack } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        Image {
            id: coverImg
            anchors.fill: parent
            source: root.mprisPlayer ? (root.mprisPlayer.trackArtUrl || "") : ""
            fillMode: Image.PreserveAspectCrop
            visible: source != ""
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle { width: 60; height: 60; radius: root.theme ? root.theme.radiusIsland : 8 }
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: "music_note"
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 24
            color: root.theme ? root.theme.textSub : "#A6ADC8"
            visible: !coverImg.visible
        }
    }
    
    Column {
        anchors.left: albumArt.right
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        
        property bool isVisible: root.islandState === State.IslandState.expanded
        opacity: (root.islandState === State.IslandState.expanded) ? 1 : 0
        transform: Translate {
            y: (root.islandState === State.IslandState.expanded) ? 0 : 10
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        Text {
            text: root.mprisPlayer ? (root.mprisPlayer.trackTitle || "No Media") : "No Media"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 16
            font.bold: true
            color: root.theme ? root.theme.textMain : "#FFF"
            width: 250
            elide: Text.ElideRight
        }
        Text {
            text: root.mprisPlayer ? (root.mprisPlayer.trackArtist || "") : ""
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            color: root.theme ? root.theme.textSub : "#A6ADC8"
            width: 250
            elide: Text.ElideRight
        }
        // Source Indicator
        Item {
            width: sourceRow.width
            height: sourceRow.height
            visible: root.mprisPlayer && root.mprisPlayer.identity
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.cyclePlayer();
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 4
                    color: parent.containsMouse ? Qt.rgba(255,255,255,0.1) : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            Row {
                id: sourceRow
                spacing: 4
                anchors.centerIn: parent
                
                Text {
                    text: "cast"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 10
                    color: sourceRow.parent.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.accentPrimary : "#00FFCC")
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                Text {
                    text: root.mprisPlayer ? (root.mprisPlayer.identity || "Unknown Source").toUpperCase() : ""
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 0.5
                    color: sourceRow.parent.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.accentPrimary : "#00FFCC")
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}
