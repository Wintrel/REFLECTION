import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property var theme: null
    property var mprisPlayer: null
    
    // Derived states
    property bool hasLyrics: mprisPlayer && mprisPlayer.currentLyrics !== ""
    property bool hasSynced: mprisPlayer && mprisPlayer.hasSyncedLyrics && mprisPlayer.parsedLyrics && mprisPlayer.parsedLyrics.length > 0
    property real currentPos: mprisPlayer ? mprisPlayer.position / 1000000 : 0
    
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
    
    // Auto-scroll logic
    onActiveLyricIndexChanged: {
        if (activeLyricIndex >= 0 && syncedView.contentHeight > syncedView.height && !syncedView.dragging && !syncedView.flicking) {
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
            
            Behavior on font.pixelSize { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
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
