import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property var mprisPlayer: null
    property var theme: null
    
    property real lastMprisAction: 0
    function canSendMpris() {
        var now = Date.now();
        if (now - lastMprisAction > 400) {
            lastMprisAction = now;
            return true;
        }
        return false;
    }
    
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
                
                property real _smoothedPos: 0
                property real _rawPos: root.mprisPlayer ? root.mprisPlayer.position : 0
                
                on_RawPosChanged: {
                    let p = _rawPos;
                    if (p === 0 || p >= _smoothedPos || (_smoothedPos - p) > 1500000) {
                        _smoothedPos = p;
                    }
                }
                
                property real computedWidth: {
                    if (progressBar.isDragging) return parent.width * progressBar.dragRatio;
                    return root.mprisPlayer && root.mprisPlayer.length > 0 ? (parent.width * (_smoothedPos / root.mprisPlayer.length)) : 0;
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
