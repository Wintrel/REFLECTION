import QtQuick

Rectangle {
    id: root

    property int islandState: 0
    property var mprisPlayer: null
    property var theme: null
    
    property bool isVisible: root.islandState === 2
    opacity: (root.islandState === 2) ? 1 : 0
    transform: Translate {
        y: (root.islandState === 2) ? 0 : 10
        Behavior on y { SequentialAnimation { PauseAnimation { duration: 150 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
    }
    Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 150 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
    
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
        color: root.theme ? root.theme.accentMusic : "#5611f8"
        
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
            if (root.isDragging) return parent.width * root.dragRatio;
            return root.mprisPlayer && root.mprisPlayer.length > 0 ? (parent.width * (_smoothedPos / root.mprisPlayer.length)) : 0;
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
    
    MouseArea {
        id: maProgress
        anchors.fill: parent
        anchors.margins: -10
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        function updateRatio(mouse) {
            var localX = mouse.x + anchors.leftMargin
            var ratio = Math.max(0, Math.min(1, localX / root.width))
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
