import "../../../../../core/state" as State
import QtQuick

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null
    
    property bool isVisible: root.islandState === State.IslandState.expanded
    opacity: (root.islandState === State.IslandState.expanded) ? 1 : 0
    transform: Translate {
        y: (root.islandState === State.IslandState.expanded) ? 0 : 10
        Behavior on y { SequentialAnimation { PauseAnimation { duration: 150 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
    }
    Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 150 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
    
    height: 24
    
    property bool isDragging: false
    property real dragRatio: 0
    
    function formatTime(raw) {
        if (!root.mprisPlayer || raw <= 0) return "0:00";
        var seconds = raw;
        if (root.mprisPlayer.identity === "Cider") seconds = raw / 1000000;
        var mins = Math.floor(seconds / 60);
        var secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
    
    // Current time label
    Text {
        id: currentTimeLabel
        anchors.left: parent.left
        anchors.verticalCenter: progressTrack.verticalCenter
        text: root.formatTime(fillRect._smoothedPos)
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 11
        color: root.theme ? root.theme.textSub : "#94A3B8"
    }
    
    // Total time label
    Text {
        id: totalTimeLabel
        anchors.right: parent.right
        anchors.verticalCenter: progressTrack.verticalCenter
        text: root.formatTime(root.mprisPlayer ? root.mprisPlayer.length : 0)
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 11
        color: root.theme ? root.theme.textSub : "#94A3B8"
    }
    
    // Progress track
    Rectangle {
        id: progressTrack
        anchors.left: currentTimeLabel.right
        anchors.leftMargin: 10
        anchors.right: totalTimeLabel.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        
        height: (maProgress.containsMouse || root.isDragging) ? 8 : 6
        radius: height / 2
        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        color: Qt.rgba(1, 1, 1, 0.1)
        
        Rectangle {
            id: fillRect
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.theme ? root.theme.accentMusic : "#5611f8" }
                GradientStop { position: 1.0; color: root.theme ? root.theme.accentPrimary : "#00FFFF" }
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
                running: root.mprisPlayer && root.mprisPlayer.isPlaying && !root.isDragging && root.mprisPlayer.identity !== "Cider"
                repeat: true
                onTriggered: {
                    fillRect._smoothedPos += 0.032;
                    if (root.mprisPlayer && fillRect._smoothedPos > root.mprisPlayer.length) {
                        fillRect._smoothedPos = root.mprisPlayer.length;
                    }
                }
            }
            
            property real computedWidth: {
                if (root.isDragging) return progressTrack.width * root.dragRatio;
                return root.mprisPlayer && root.mprisPlayer.length > 0 ? (progressTrack.width * (_smoothedPos / root.mprisPlayer.length)) : 0;
            }
            width: computedWidth
            
            Behavior on width {
                id: widthBehavior
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        // Thumb dot removed for minimal desktop density
        // The track thickening to 6px on hover provides enough feedback.
        
        MouseArea {
            id: maProgress
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            function updateRatio(mouse) {
                var localX = mouse.x + anchors.leftMargin
                var ratio = Math.max(0, Math.min(1, localX / progressTrack.width))
                root.dragRatio = ratio
            }
            
            onPressed: (mouse) => {
                root.isDragging = true
                updateRatio(mouse)
            }
            onPositionChanged: (mouse) => {
                if (root.isDragging) updateRatio(mouse)
            }
            onReleased: (mouse) => {
                if (root.isDragging) {
                    updateRatio(mouse)
                    root.isDragging = false
                    if (root.mprisPlayer && root.mprisPlayer.length > 0 && root.mprisPlayer.canSeek) {
                        root.mprisPlayer.position = root.dragRatio * root.mprisPlayer.length
                    }
                }
            }
        }
    }
}
