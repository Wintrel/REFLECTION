import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property var theme: null
    property var mprisPlayer: null
    
    // Derived states
    property bool hasSynced: mprisPlayer && mprisPlayer.hasSyncedLyrics && mprisPlayer.parsedLyrics && mprisPlayer.parsedLyrics.length > 0
    property bool hasLyrics: hasSynced || (mprisPlayer && mprisPlayer.currentLyrics !== "")
    property real _rawPos: mprisPlayer ? mprisPlayer.position / 1000000 : 0
    property real currentPos: 0
    
    on_RawPosChanged: {
        let p = _rawPos;
        // Ignore stale time packets that jump backward by less than 4 seconds
        if (p === 0 || p >= currentPos || (currentPos - p) > 4.0) {
            currentPos = p;
        }
    }
    
    // Find active lyric index
    property int activeLyricIndex: {
        if (!hasSynced) return -1;
        let p = mprisPlayer.parsedLyrics;
        let idx = -1;
        for (let i = 0; i < p.length; i++) {
            if (p[i].time <= root.currentPos) {
                idx = i;
            } else {
                break;
            }
        }
        return idx;
    }
    
    // Pause auto-scroll when user manually scrolls
    property bool _userIsInteracting: syncedView.dragging || syncedView.flicking
    property bool _isUserPausedScroll: false
    
    on_UserIsInteractingChanged: {
        if (_userIsInteracting) {
            interactionTimer.stop();
            _isUserPausedScroll = true;
        } else {
            interactionTimer.restart();
        }
    }
    
    Timer {
        id: interactionTimer
        interval: 4000
        onTriggered: {
            root._isUserPausedScroll = false;
            root.scrollToActiveLyric();
        }
    }
    
    function scrollToActiveLyric() {
        if (root.visible && activeLyricIndex >= 0 && syncedView.contentHeight > syncedView.height && !_isUserPausedScroll) {
            let oldY = syncedView.contentY;
            syncedView.positionViewAtIndex(activeLyricIndex, ListView.Center);
            let targetY = syncedView.contentY;
            syncedView.contentY = oldY;
            
            if (Math.abs(targetY - oldY) > 2) {
                scrollAnim.to = targetY;
                scrollAnim.restart();
            }
        }
    }
    
    // Auto-scroll logic.
    onActiveLyricIndexChanged: {
        scrollToActiveLyric();
    }
    
    NumberAnimation {
        id: scrollAnim
        target: syncedView
        property: "contentY"
        duration: 600
        easing.type: Easing.OutQuart
    }
    
    // No Lyrics View
    Text {
        anchors.centerIn: parent
        text: "No Lyrics Available"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 16
        color: root.theme ? root.theme.textSub : "#A6ADC8"
        visible: !root.hasLyrics
    }
    
    // Synced Lyrics View
    ListView {
        id: syncedView
        anchors.fill: parent
        anchors.margins: 16
        visible: root.hasSynced
        clip: true
        spacing: 16
        model: root.hasSynced ? root.mprisPlayer.parsedLyrics : []
        
        // Add some padding to top and bottom so first/last item can be centered
        topMargin: height / 2 - 30
        bottomMargin: height / 2 - 30
        
        delegate: Text {
            width: ListView.view.width
            text: modelData.text
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: index === root.activeLyricIndex ? 24 : 16
            font.bold: index === root.activeLyricIndex
            color: index === root.activeLyricIndex ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#A6ADC8")
            opacity: index === root.activeLyricIndex ? 1.0 : 0.4
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            
            Behavior on color { ColorAnimation { duration: 300 } }
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }
    }
    
    // Plain Text Lyrics Fallback View
    Flickable {
        anchors.fill: parent
        anchors.margins: 16
        visible: root.hasLyrics && !root.hasSynced
        clip: true
        contentWidth: width
        contentHeight: fallbackText.height
        
        Text {
            id: fallbackText
            width: parent.width
            text: root.mprisPlayer ? root.mprisPlayer.currentLyrics : ""
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 16
            color: root.theme ? root.theme.textMain : "#FFF"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
