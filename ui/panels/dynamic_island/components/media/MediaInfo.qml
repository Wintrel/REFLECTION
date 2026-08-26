import "../../../../../core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null

    width: childrenRect.width
    height: 64
    
    Rectangle {
        id: albumArt
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 92
        height: 92
        radius: 22
        color: (currentCoverImg.opacity > 0 || prevCoverImg.opacity > 0) ? "transparent" : (root.theme ? root.theme.surfaceOverlay : "#313244")
        
        property bool isVisible: root.islandState === State.IslandState.expanded
        opacity: (root.islandState === State.IslandState.expanded) ? 1 : 0
        scale: albumArtMa.pressed ? 0.95 : (albumArtMa.containsMouse ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        transform: Scale {
            origin.x: 32; origin.y: 32
            xScale: (root.islandState === State.IslandState.expanded) ? 1 : 0.8
            yScale: (root.islandState === State.IslandState.expanded) ? 1 : 0.8
            Behavior on xScale { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutBack } } }
            Behavior on yScale { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutBack } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        // ── Rotating Mask Source ──────────────────────────────────────
        Item {
            id: maskContainer
            anchors.fill: parent
            visible: false

            Image {
                id: maskBadge
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                source: Qt.resolvedUrl("../../../../../assets/m3_badge.svg")
                fillMode: Image.PreserveAspectFit

                NumberAnimation on rotation {
                    running: root.islandState === State.IslandState.expanded 
                             && root.mprisPlayer 
                             && root.mprisPlayer.isPlaying
                    from: 0
                    to: 360
                    duration: 24000 // Smooth, continuous 24s revolution
                    loops: Animation.Infinite
                }
            }
        }

        // ── Smooth Image Crossfading Logic ────────────────────────────
        property string rawTrackArtUrl: root.mprisPlayer ? (root.mprisPlayer.trackArtUrl || "") : ""
        property string activeArtUrl: ""
        property string prevArtUrl: ""

        onRawTrackArtUrlChanged: {
            if (rawTrackArtUrl === activeArtUrl) return;
            if (activeArtUrl !== "" && currentCoverImg.status === Image.Ready) {
                prevArtUrl = activeArtUrl;
                prevCoverImg.opacity = 1.0;
            }
            activeArtUrl = rawTrackArtUrl;
            if (activeArtUrl === "") {
                prevArtUrl = "";
                prevCoverImg.opacity = 0.0;
            }
        }

        // Previous Cover Image (fades out as new one finishes loading)
        Image {
            id: prevCoverImg
            anchors.fill: parent
            source: albumArt.prevArtUrl
            fillMode: Image.PreserveAspectCrop
            visible: opacity > 0 && source != ""
            opacity: 0.0
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: maskContainer
            }
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
        }

        // Active / New Cover Image (smoothly fades in once loaded)
        Image {
            id: currentCoverImg
            anchors.fill: parent
            source: albumArt.activeArtUrl
            fillMode: Image.PreserveAspectCrop
            visible: opacity > 0 && source != ""
            opacity: (status === Image.Ready && albumArt.activeArtUrl !== "") ? 1.0 : 0.0
            
            onStatusChanged: {
                if (status === Image.Ready) {
                    prevCoverImg.opacity = 0.0;
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: maskContainer
            }
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
        }
        
        // Fallback Icon if no album art is present
        Text {
            anchors.centerIn: parent
            text: "music_note"
            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 24
            color: root.theme ? root.theme.textSub : "#A6ADC8"
            visible: currentCoverImg.opacity === 0 && prevCoverImg.opacity === 0
        }

        // Hover Overlay with Play / Pause Indicator
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.35)
            opacity: albumArtMa.containsMouse ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            visible: opacity > 0 && root.mprisPlayer

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: maskContainer
            }

            Text {
                anchors.centerIn: parent
                text: root.mprisPlayer && root.mprisPlayer.isPlaying ? "pause" : "play_arrow"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 32
                color: "#FFFFFF"
            }
        }

        // Click to Play / Pause MouseArea
        MouseArea {
            id: albumArtMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.mprisPlayer) {
                    root.mprisPlayer.togglePlaying();
                }
            }
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
        // Spacer to push the source button down slightly
        Item { 
            height: 6 
            width: 1 
            visible: root.mprisPlayer && root.mprisPlayer.identity 
        }
        
        // Source Indicator
        Item {
            width: sourceRow.width + 16
            height: sourceRow.height + 10
            visible: root.mprisPlayer && root.mprisPlayer.identity
            
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: maSource.containsMouse ? 
                       (root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.2) : Qt.rgba(255, 255, 255, 0.12)) : 
                       (root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.06))
                border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.5) : Qt.rgba(255, 255, 255, 0.1)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            MouseArea {
                id: maSource
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.cyclePlayer();
                    }
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
