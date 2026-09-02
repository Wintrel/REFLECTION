import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../../core/services/media"

Item {
    id: root

    property var mprisPlayer: null
    property var theme: null

    height: 84

    property real lastMprisAction: 0
    function canSendMpris() {
        var now = Date.now();
        if (now - lastMprisAction > 350) {
            lastMprisAction = now;
            return true;
        }
        return false;
    }

    function formatTime(raw) {
        if (!root.mprisPlayer || raw <= 0) return "0:00";
        var seconds = raw;
        if (root.mprisPlayer.identity === "Cider") seconds = raw / 1000000;
        var mins = Math.floor(seconds / 60);
        var secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    // ── Main Top Area: Album Info, Floating Pill Dock, Volume/Fav ────────
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: progressDeck.top
        anchors.bottomMargin: 4

        // ── LEFT: Rosetta Album Art & Track Metadata ─────────────────────
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            // Rosetta Rotating Album Art
            Rectangle {
                id: albumArt
                width: 60
                height: 60
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                color: (currentCoverImg.opacity > 0 || prevCoverImg.opacity > 0) ? "transparent" : (root.theme ? root.theme.surfaceOverlay : "#313244")

                scale: albumArtMa.pressed ? 0.93 : (albumArtMa.containsMouse ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                // ── Rotating Mask Source ──
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
                            running: root.mprisPlayer && root.mprisPlayer.isPlaying
                            from: 0
                            to: 360
                            duration: 24000
                            loops: Animation.Infinite
                        }
                    }
                }

                // ── Crossfade Logic ──
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
                    Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
                }

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
                    Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
                }

                // Fallback icon
                Text {
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 22
                    color: root.theme ? root.theme.textSub : "#A6ADC8"
                    visible: currentCoverImg.opacity === 0 && prevCoverImg.opacity === 0
                }

                // Hover Play/Pause Overlay
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, 0.38)
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
                        font.pixelSize: 24
                        color: "#FFFFFF"
                    }
                }

                MouseArea {
                    id: albumArtMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.mprisPlayer && root.canSendMpris()) {
                            root.mprisPlayer.togglePlaying();
                        }
                    }
                }
            }

            // Track Title, Artist, & Badges
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                width: 240

                Text {
                    text: root.mprisPlayer ? (root.mprisPlayer.trackTitle || "No Media") : "No Media"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 15
                    font.bold: true
                    color: root.theme ? root.theme.textMain : "#FFF"
                    width: parent.width
                    elide: Text.ElideRight
                }

                Row {
                    spacing: 6
                    width: parent.width

                    Text {
                        text: root.mprisPlayer ? (root.mprisPlayer.trackArtist || "Unknown Artist") : "Standby"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        color: root.theme ? root.theme.textSub : "#A6ADC8"
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: Math.min(implicitWidth, 160)
                    }

                    // Explicit [E] Badge
                    Rectangle {
                        visible: root.mprisPlayer && (root.mprisPlayer.isExplicit === true || (root.mprisPlayer.currentTrack && root.mprisPlayer.currentTrack.isExplicit))
                        width: 14; height: 14
                        radius: 3
                        color: Qt.rgba(255, 255, 255, 0.16)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "E"
                            font.pixelSize: 9
                            font.bold: true
                            color: root.theme ? root.theme.textMain : "#FFF"
                        }
                    }

                    // Dolby Atmos / Lossless Badge
                    Rectangle {
                        visible: root.mprisPlayer && (CiderService.atmosEnabled || root.mprisPlayer.identity === "Cider")
                        height: 14
                        width: badgeTxt.width + 8
                        radius: 7
                        color: Qt.rgba(root.theme ? root.theme.accentMusic.r : 0.5, root.theme ? root.theme.accentMusic.g : 0.5, root.theme ? root.theme.accentMusic.b : 1.0, 0.18)
                        border.width: 1
                        border.color: Qt.rgba(root.theme ? root.theme.accentMusic.r : 0.5, root.theme ? root.theme.accentMusic.g : 0.5, root.theme ? root.theme.accentMusic.b : 1.0, 0.35)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: badgeTxt
                            anchors.centerIn: parent
                            text: CiderService.atmosEnabled ? "ATMOS" : "LOSSLESS"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 8
                            font.bold: true
                            color: root.theme ? root.theme.accentMusic : "#7C9CFF"
                        }
                    }
                }
            }
        }

        // ── CENTER: Floating Pill Transport Dock ────────────────────────
        Rectangle {
            id: transportDock
            anchors.centerIn: parent
            width: controlsRow.width + 20
            height: 48
            radius: height / 2
            color: root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.05)
            border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.25) : Qt.rgba(255, 255, 255, 0.08)
            border.width: 1

            Row {
                id: controlsRow
                anchors.centerIn: parent
                spacing: 10

                // Shuffle Button
                Item {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    readonly property bool isActive: root.mprisPlayer && root.mprisPlayer.shuffleMode > 0

                    Text {
                        id: btnShuffle
                        anchors.centerIn: parent
                        text: "shuffle"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: parent.isActive
                               ? (root.theme ? root.theme.accentPrimary : "#00FFCC")
                               : (maShuffle.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#888"))
                        scale: maShuffle.pressed ? 0.85 : (maShuffle.containsMouse ? 1.12 : 1)
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    // Active dot indicator
                    Rectangle {
                        visible: parent.isActive
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 4
                        height: 4
                        radius: 2
                        color: root.theme ? root.theme.accentPrimary : "#00FFCC"
                    }

                    MouseArea {
                        id: maShuffle
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris() && typeof root.mprisPlayer.toggleShuffle === 'function') {
                                root.mprisPlayer.toggleShuffle();
                            }
                        }
                    }
                }

                // Previous Button
                Item {
                    width: 34
                    height: 34
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: btnPrev
                        anchors.centerIn: parent
                        text: "skip_previous"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 24
                        color: maPrev.pressed
                               ? (root.theme ? root.theme.accentPrimary : "#FFF")
                               : (maPrev.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#94A3B8"))
                        scale: maPrev.pressed ? 0.85 : (maPrev.containsMouse ? 1.12 : 1)
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: maPrev
                        anchors.fill: parent
                        hoverEnabled: true
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

                // Hero Play/Pause Button
                Rectangle {
                    id: playPauseBtn
                    width: 38
                    height: 38
                    radius: 19
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.theme ? root.theme.accentPrimary : "#5151ad"

                    scale: maPlay.pressed ? 0.85 : (maPlay.containsMouse ? 1.08 : 1)
                    Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 250 } }

                    Text {
                        anchors.centerIn: parent
                        text: (root.mprisPlayer && root.mprisPlayer.isPlaying) ? "pause" : "play_arrow"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 22
                        color: root.theme ? root.theme.bgBase : "#000"
                    }

                    MouseArea {
                        id: maPlay
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris()) {
                                root.mprisPlayer.togglePlaying();
                            }
                        }
                    }
                }

                // Next Button
                Item {
                    width: 34
                    height: 34
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: btnNext
                        anchors.centerIn: parent
                        text: "skip_next"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 24
                        color: maNext.pressed
                               ? (root.theme ? root.theme.accentPrimary : "#FFF")
                               : (maNext.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#94A3B8"))
                        scale: maNext.pressed ? 0.85 : (maNext.containsMouse ? 1.12 : 1)
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: maNext
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris()) {
                                root.mprisPlayer.next();
                            }
                        }
                    }
                }

                // Repeat Button
                Item {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter

                    readonly property bool isActive: root.mprisPlayer && root.mprisPlayer.repeatMode > 0
                    readonly property bool isOne: root.mprisPlayer && root.mprisPlayer.repeatMode === 1

                    Text {
                        id: btnRepeat
                        anchors.centerIn: parent
                        text: parent.isOne ? "repeat_one" : "repeat"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: parent.isActive
                               ? (root.theme ? root.theme.accentPrimary : "#00FFCC")
                               : (maRepeat.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#888"))
                        scale: maRepeat.pressed ? 0.85 : (maRepeat.containsMouse ? 1.12 : 1)
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    // Active dot indicator
                    Rectangle {
                        visible: parent.isActive
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 4
                        height: 4
                        radius: 2
                        color: root.theme ? root.theme.accentPrimary : "#00FFCC"
                    }

                    MouseArea {
                        id: maRepeat
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.mprisPlayer && root.canSendMpris() && typeof root.mprisPlayer.toggleRepeat === 'function') {
                                root.mprisPlayer.toggleRepeat();
                            }
                        }
                    }
                }
            }
        }

        // ── RIGHT: Favorite & Interactive Volume Pill ────────────────────
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            // Favorite Button with Spring Punch
            Item {
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter

                property bool inFav: root.mprisPlayer ? (root.mprisPlayer.inFavorites === true) : false

                Text {
                    id: iconFavorite
                    anchors.centerIn: parent
                    text: parent.inFav ? "favorite" : "favorite_border"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: parent.inFav ? "#F38BA8" : (favMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8"))
                    Behavior on color { ColorAnimation { duration: 200 } }

                    scale: favMa.pressed ? 0.85 : (parent.inFav ? favSpringScale.val : (favMa.containsMouse ? 1.12 : 1))
                    Behavior on scale { NumberAnimation { duration: 150 } }

                    QtObject {
                        id: favSpringScale
                        property real val: 1.0
                        Behavior on val { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                    }
                }

                MouseArea {
                    id: favMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.mprisPlayer && typeof root.mprisPlayer.toggleFavorite === 'function') {
                            favSpringScale.val = 1.35;
                            root.mprisPlayer.toggleFavorite();
                            resetTimer.restart();
                        }
                    }
                }

                Timer {
                    id: resetTimer
                    interval: 150
                    onTriggered: favSpringScale.val = 1.0
                }
            }

            // Volume Pill Slider
            Rectangle {
                id: volContainer
                height: 32
                width: volRow.width + 16
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                color: root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.04)
                border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.2) : Qt.rgba(255, 255, 255, 0.08)
                border.width: 1

                Row {
                    id: volRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (!root.mprisPlayer) return "volume_up";
                            if (root.mprisPlayer.volume === 0) return "volume_mute";
                            if (root.mprisPlayer.volume < 0.5) return "volume_down";
                            return "volume_up";
                        }
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: volSpeakerMa.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")

                        MouseArea {
                            id: volSpeakerMa
                            anchors.fill: parent
                            anchors.margins: -4
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.mprisPlayer && typeof root.mprisPlayer.setVolume === 'function') {
                                    if (root.mprisPlayer.volume > 0) {
                                        volTrack._savedVolume = root.mprisPlayer.volume;
                                        root.mprisPlayer.setVolume(0);
                                    } else {
                                        root.mprisPlayer.setVolume(volTrack._savedVolume || 0.5);
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: volTrack
                        property real _savedVolume: 0.5
                        width: 80
                        height: (volMa.containsMouse || volMa.isDragging) ? 6 : 4
                        radius: height / 2
                        color: Qt.rgba(255, 255, 255, 0.12)
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            radius: parent.radius
                            color: root.theme ? root.theme.textMain : "#FFF"
                            width: root.mprisPlayer ? parent.width * Math.max(0, Math.min(1, root.mprisPlayer.volume)) : 0
                            Behavior on width { NumberAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: volMa
                            anchors.fill: parent
                            anchors.margins: -8
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

    // ── BOTTOM: M3 Progress Bar with Timestamps ──────────────────────────
    Item {
        id: progressDeck
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 20

        // Current Elapsed Time
        Text {
            id: currentTimeLabel
            anchors.left: parent.left
            anchors.verticalCenter: progressBar.verticalCenter
            text: root.formatTime(fillRect._smoothedPos)
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 11
            color: root.theme ? root.theme.textSub : "#94A3B8"
        }

        // Total Length Time
        Text {
            id: totalTimeLabel
            anchors.right: parent.right
            anchors.verticalCenter: progressBar.verticalCenter
            text: root.formatTime(root.mprisPlayer ? root.mprisPlayer.length : 0)
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 11
            color: root.theme ? root.theme.textSub : "#94A3B8"
        }

        // Progress Slider
        Rectangle {
            id: progressBar
            anchors.left: currentTimeLabel.right
            anchors.leftMargin: 10
            anchors.right: totalTimeLabel.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            height: (maProgress.containsMouse || isDragging) ? 8 : 4
            radius: height / 2
            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            color: (maProgress.containsMouse || isDragging) ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.08)
            Behavior on color { ColorAnimation { duration: 200 } }

            property bool isDragging: false
            property real dragRatio: 0

            Rectangle {
                id: fillRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.theme ? root.theme.accentMusic : "#5611f8" }
                    GradientStop { position: 1.0; color: root.theme ? root.theme.accentPrimary : "#7C9CFF" }
                }

                property real _smoothedPos: 0
                property real _rawPos: root.mprisPlayer ? root.mprisPlayer.position : 0

                on_RawPosChanged: {
                    let p = _rawPos;
                    let isCider = root.mprisPlayer && root.mprisPlayer.identity === "Cider";
                    let threshold = isCider ? 1500000 : 1.5;

                    if (p === 0 || Math.abs(_smoothedPos - p) > threshold) {
                        _smoothedPos = p;
                    }
                }

                Timer {
                    interval: 32
                    running: root.mprisPlayer && root.mprisPlayer.isPlaying && !progressBar.isDragging && root.mprisPlayer.identity !== "Cider"
                    repeat: true
                    onTriggered: {
                        fillRect._smoothedPos += 0.032;
                        if (root.mprisPlayer && fillRect._smoothedPos > root.mprisPlayer.length) {
                            fillRect._smoothedPos = root.mprisPlayer.length;
                        }
                    }
                }

                property real computedWidth: {
                    if (progressBar.isDragging) return parent.width * progressBar.dragRatio;
                    return root.mprisPlayer && root.mprisPlayer.length > 0 ? (parent.width * Math.max(0, Math.min(1, _smoothedPos / root.mprisPlayer.length))) : 0;
                }
                width: computedWidth

                Behavior on width {
                    NumberAnimation {
                        duration: progressBar.isDragging ? 0 : 250
                        easing.type: Easing.OutQuad
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
                    var ratio = Math.max(0, Math.min(1, mouse.x / progressBar.width));
                    progressBar.dragRatio = ratio;
                }

                onPressed: (mouse) => {
                    progressBar.isDragging = true;
                    updateRatio(mouse);
                }
                onPositionChanged: (mouse) => {
                    if (progressBar.isDragging) updateRatio(mouse);
                }
                onReleased: (mouse) => {
                    if (progressBar.isDragging) {
                        updateRatio(mouse);
                        progressBar.isDragging = false;
                        if (root.mprisPlayer && root.mprisPlayer.length > 0 && root.mprisPlayer.canSeek) {
                            root.mprisPlayer.position = progressBar.dragRatio * root.mprisPlayer.length;
                        }
                    }
                }
            }
        }
    }
}
