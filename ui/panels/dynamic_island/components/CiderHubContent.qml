import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root
    
    property int islandState: 0
    property var mprisPlayer: null
    property var theme: null
    property real islandCiderW: 800
    property real islandCiderH: 550
    
    property real lastMprisAction: 0
    property int currentTab: 0 // 0: Queue, 1: Search, 2: Lyrics
    
    function canSendMpris() {
        var now = Date.now();
        if (now - lastMprisAction > 400) {
            lastMprisAction = now;
            return true;
        }
        return false;
    }
    
    width: islandCiderW - 32
    height: islandCiderH - 32
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: (islandCiderH - height) / 2
    
    opacity: root.islandState === 13 ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
    
    // Starfield Voidy
    Components.Starfield {
        anchors.fill: parent
        anchors.margins: -8
        visible: root.visible
        starColor: root.theme ? root.theme.textMain : "#ffffff"
        opacity: 0.85
    }
    
    // Background Visualizer
    Components.MusicVisualizer {
        id: bgVisualizer
        anchors.fill: parent
        anchors.margins: -8
        isPlaying: root.islandState === 13 && (root.mprisPlayer ? root.mprisPlayer.isPlaying : false)
        accentColor: root.theme ? root.theme.colorMusic : "#5611f8"
    }

    // ==========================================
    // TOP AREA: Navigation
    // ==========================================
    Item {
        id: topSliver
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        
        property bool isVisible: root.islandState === 13
        opacity: (root.islandState === 13) ? 1 : 0
        transform: Translate {
            y: (root.islandState === 13) ? 0 : -5
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        // Close Button (Left)
        Item {
            anchors.left: parent.left
            width: 32
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                text: "close_fullscreen"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 18
                color: root.theme ? root.theme.textSub : "#A6ADC8"
                scale: collapseMa.pressed ? 0.9 : (collapseMa.containsMouse ? 1.1 : 1)
                opacity: collapseMa.pressed ? 0.7 : 1
                Behavior on scale { NumberAnimation { duration: 150 } }
                
                MouseArea {
                    id: collapseMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = 2;
                        }
                    }
                }
            }
        }
        
        // Tabs (Center)
        Row {
            anchors.centerIn: parent
            spacing: 32
            
            // Tab 0: Queue
            Item {
                width: tabQueueText.width
                height: 24
                Text {
                    id: tabQueueText
                    anchors.centerIn: parent
                    text: "Up Next"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.currentTab === 0 ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.currentTab === 0 ? parent.width : 0
                    height: 2
                    radius: 1
                    color: root.theme ? root.theme.textMain : "#FFF"
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.currentTab = 0 }
            }
            
            // Tab 1: Search (Placeholder)
            Item {
                width: tabSearchText.width
                height: 24
                Text {
                    id: tabSearchText
                    anchors.centerIn: parent
                    text: "Search"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.currentTab === 1 ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.currentTab === 1 ? parent.width : 0
                    height: 2
                    radius: 1
                    color: root.theme ? root.theme.textMain : "#FFF"
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.currentTab = 1 }
            }
            
            // Tab 2: Lyrics (Placeholder)
            Item {
                width: tabLyricsText.width
                height: 24
                Text {
                    id: tabLyricsText
                    anchors.centerIn: parent
                    text: "Lyrics"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.currentTab === 2 ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.currentTab === 2 ? parent.width : 0
                    height: 2
                    radius: 1
                    color: root.theme ? root.theme.textMain : "#FFF"
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.currentTab = 2 }
            }
        }
    }

    // ==========================================
    // MIDDLE AREA: Dynamic Content
    // ==========================================
    Item {
        id: middleArea
        anchors.top: topSliver.bottom
        anchors.topMargin: 20
        anchors.bottom: bottomArea.top
        anchors.bottomMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right

        // Tab 0: Queue Content
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
            radius: 12
            clip: true
            opacity: root.currentTab === 0 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            
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
        
        // Tab 1: Search Content Placeholder
        Item {
            anchors.fill: parent
            opacity: root.currentTab === 1 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            
            Text {
                anchors.centerIn: parent
                text: "Search feature coming soon."
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 16
                color: root.theme ? root.theme.textSub : "#A6ADC8"
            }
        }
        
        // Tab 2: Lyrics Content Placeholder
        Item {
            anchors.fill: parent
            opacity: root.currentTab === 2 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            
            Text {
                anchors.centerIn: parent
                text: "Lyrics feature coming soon."
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 16
                color: root.theme ? root.theme.textSub : "#A6ADC8"
            }
        }
    }

    // ==========================================
    // BOTTOM AREA: Media Player Controls
    // ==========================================
    Item {
        id: bottomArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        
        property bool isVisible: root.islandState === 13
        opacity: (root.islandState === 13) ? 1 : 0
        transform: Translate {
            y: (root.islandState === 13) ? 0 : 10
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        // Progress Bar (Spanning across the bottom edge)
        Rectangle {
            id: progressBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: 4
            
            height: (maProgress.containsMouse || isDragging) ? 10 : 6
            radius: height / 2
            Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            color: (maProgress.containsMouse || isDragging) ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(0, 0, 0, 0.5)
            Behavior on color { ColorAnimation { duration: 200 } }
            
            property bool isDragging: false
            property real dragRatio: 0
            
            Rectangle {
                id: fillRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: parent.radius
                color: root.theme ? root.theme.colorMusic : "#5611f8"
                
                property real computedWidth: {
                    if (progressBar.isDragging) return parent.width * progressBar.dragRatio;
                    return root.mprisPlayer && root.mprisPlayer.length > 0 ? (parent.width * (root.mprisPlayer.position / root.mprisPlayer.length)) : 0;
                }
                width: computedWidth
                
                Behavior on width {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            MouseArea {
                id: maProgress
                anchors.fill: parent
                anchors.margins: -10
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                function updateRatio(mouse) {
                    var localX = mouse.x
                    var ratio = Math.max(0, Math.min(1, localX / progressBar.width))
                    progressBar.dragRatio = ratio
                }
                
                onPressed: (mouse) => {
                    progressBar.isDragging = true
                    updateRatio(mouse)
                }
                onPositionChanged: (mouse) => {
                    if (progressBar.isDragging) updateRatio(mouse)
                }
                onReleased: (mouse) => {
                    if (progressBar.isDragging) {
                        updateRatio(mouse)
                        progressBar.isDragging = false
                        if (root.mprisPlayer && root.mprisPlayer.length > 0 && root.mprisPlayer.canSeek) {
                            root.mprisPlayer.position = progressBar.dragRatio * root.mprisPlayer.length
                        }
                    }
                }
            }
        }
        
        // Track Info & Controls
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: progressBar.top
            anchors.bottomMargin: 8
            
            // Left: Album Art + Track Info
            Rectangle {
                id: albumArt
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 60
                height: 60
                radius: 8
                color: "#313244"
                
                Image {
                    id: coverImg
                    anchors.fill: parent
                    source: root.mprisPlayer ? (root.mprisPlayer.trackArtUrl || "") : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source != ""
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle { width: 60; height: 60; radius: 8 }
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
                
                Text {
                    text: root.mprisPlayer ? (root.mprisPlayer.trackTitle || "No Media") : "No Media"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 16
                    font.bold: true
                    color: root.theme ? root.theme.textMain : "#FFF"
                    width: 300
                    elide: Text.ElideRight
                }
                Text {
                    text: root.mprisPlayer ? (root.mprisPlayer.trackArtist || "") : ""
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    color: root.theme ? root.theme.textSub : "#A6ADC8"
                    width: 300
                    elide: Text.ElideRight
                }
            }
            
            // Center: Playback Controls (Shuffle, Prev, Play, Next, Repeat)
            Row {
                anchors.centerIn: parent
                spacing: 20
                
                Text { 
                    id: btnShuffle
                    text: "shuffle"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 28
                    property bool isActive: root.mprisPlayer && root.mprisPlayer.shuffleMode > 0
                    color: isActive ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.3)
                    anchors.verticalCenter: parent.verticalCenter 
                    
                    scale: maShuffle.pressed ? 0.85 : (maShuffle.containsMouse ? 1.1 : 1)
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    MouseArea { 
                        id: maShuffle
                        anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris() && typeof root.mprisPlayer.toggleShuffle === 'function') {
                                root.mprisPlayer.toggleShuffle();
                            }
                        }
                    }
                }

                Text { 
                    id: btnPrev
                    text: "skip_previous"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 32
                    color: maPrev.pressed ? (root.theme ? root.theme.colorMusic : "#5611f8") : (maPrev.containsMouse ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : (root.theme ? root.theme.textMain : "#FFF"))
                    anchors.verticalCenter: parent.verticalCenter 
                    
                    scale: maPrev.pressed ? 0.85 : (maPrev.containsMouse ? 1.1 : 1)
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    MouseArea { 
                        id: maPrev
                        anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris()) {
                                var threshold = root.mprisPlayer.length > 10000 ? 3000000 : 3;
                                if (root.mprisPlayer.position > threshold && root.mprisPlayer.canSeek) {
                                    root.mprisPlayer.position = 0;
                                } else {
                                    root.mprisPlayer.previous();
                                }
                            }
                        }
                    }
                }
                
                Text { 
                    id: btnPlay
                    text: (root.mprisPlayer && root.mprisPlayer.isPlaying) ? "pause_circle" : "play_circle"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 42
                    color: maPlay.pressed ? (root.theme ? root.theme.colorMusic : "#5611f8") : (maPlay.containsMouse ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : (root.theme ? root.theme.textMain : "#FFF"))
                    anchors.verticalCenter: parent.verticalCenter 
                    
                    scale: maPlay.pressed ? 0.85 : (maPlay.containsMouse ? 1.05 : 1)
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    MouseArea { 
                        id: maPlay
                        anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.mprisPlayer && root.canSendMpris()) root.mprisPlayer.togglePlaying() 
                    }
                }
                
                Text { 
                    id: btnNext
                    text: "skip_next"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 32
                    color: maNext.pressed ? (root.theme ? root.theme.colorMusic : "#5611f8") : (maNext.containsMouse ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : (root.theme ? root.theme.textMain : "#FFF"))
                    anchors.verticalCenter: parent.verticalCenter 
                    
                    scale: maNext.pressed ? 0.85 : (maNext.containsMouse ? 1.1 : 1)
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    MouseArea { 
                        id: maNext
                        anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris()) {
                                root.mprisPlayer.next();
                            }
                        }
                    }
                }
                
                Text { 
                    id: btnRepeat
                    text: (root.mprisPlayer && root.mprisPlayer.repeatMode === 1) ? "repeat_one" : "repeat"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 28
                    property bool isActive: root.mprisPlayer && root.mprisPlayer.repeatMode > 0
                    color: isActive ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.3)
                    anchors.verticalCenter: parent.verticalCenter 
                    
                    scale: maRepeat.pressed ? 0.85 : (maRepeat.containsMouse ? 1.1 : 1)
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    MouseArea { 
                        id: maRepeat
                        anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris() && typeof root.mprisPlayer.toggleRepeat === 'function') {
                                root.mprisPlayer.toggleRepeat();
                            }
                        }
                    }
                }
            }
            
            // Right: Volume & Favorite
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 24
                
                // Read-only Favorite Icon
                Text {
                    id: iconFavorite
                    text: (root.mprisPlayer && root.mprisPlayer.inFavorites) ? "favorite" : "favorite_border"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 26
                    color: (root.mprisPlayer && root.mprisPlayer.inFavorites) ? "#F38BA8" : (root.theme ? root.theme.textSub : "#A6ADC8")
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    
                    // Simple hover effect, read-only
                    scale: favMa.containsMouse ? 1.1 : 1
                    Behavior on scale { NumberAnimation { duration: 150 } }
                    MouseArea { id: favMa; anchors.fill: parent; anchors.margins: -5; hoverEnabled: true }
                }
                
                // Volume Control
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12
                    
                    Text {
                        text: {
                            if (!root.mprisPlayer) return "volume_up";
                            if (root.mprisPlayer.volume === 0) return "volume_mute";
                            if (root.mprisPlayer.volume < 0.5) return "volume_down";
                            return "volume_up";
                        }
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 24
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Rectangle {
                        id: volTrack
                        width: 100
                        height: volMa.containsMouse || volMa.isDragging ? 8 : 4
                        radius: height / 2
                        color: Qt.rgba(255, 255, 255, 0.15)
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on height { NumberAnimation { duration: 150 } }
                        
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            radius: parent.radius
                            color: root.theme ? root.theme.textMain : "#FFF"
                            width: root.mprisPlayer ? parent.width * root.mprisPlayer.volume : 0
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }
                        
                        MouseArea {
                            id: volMa
                            anchors.fill: parent
                            anchors.margins: -10
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            property bool isDragging: false
                            
                            function updateVol(mouse) {
                                var ratio = Math.max(0, Math.min(1, mouse.x / volTrack.width));
                                if (root.mprisPlayer && typeof root.mprisPlayer.setVolume === 'function') {
                                    root.mprisPlayer.setVolume(ratio);
                                }
                            }
                            
                            onPressed: (mouse) => { isDragging = true; updateVol(mouse); }
                            onPositionChanged: (mouse) => { if (isDragging) updateVol(mouse); }
                            onReleased: (mouse) => { if (isDragging) { updateVol(mouse); isDragging = false; } }
                        }
                    }
                }
            }
        }
    }
}
