import "core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components
import "media" as Media

Item {
    id: root
    
    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null
    property real islandMaxW: 0
    property real islandMaxH: 0
    
    property real lastMprisAction: 0
    
    property bool isSwitchingTracks: false
    property string currentTrackTitle: root.mprisPlayer ? (root.mprisPlayer.trackTitle || "") : ""
    onCurrentTrackTitleChanged: {
        root.isSwitchingTracks = false;
        trackSwitchTimeout.stop();
    }
    
    Timer {
        id: trackSwitchTimeout
        interval: 2500
        repeat: false
        onTriggered: root.isSwitchingTracks = false;
    }
    
    function canSendMpris() {
        var now = Date.now();
        if (now - lastMprisAction > 400) {
            lastMprisAction = now;
            return true;
        }
        return false;
    }
    
    width: islandMaxW - 32
    height: islandMaxH - 32
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: (islandMaxH - height) / 2
    
    opacity: root.islandState === State.IslandState.expanded ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }
    
    Media.MediaBackground {
        anchors.fill: parent
        islandState: root.islandState
        mprisPlayer: root.mprisPlayer
        theme: root.theme
        isSwitchingTracks: root.isSwitchingTracks
    }
    
    Media.ExpandedTopBar {
        id: topSliver
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        islandState: root.islandState
        mprisPlayer: root.mprisPlayer
        theme: root.theme
    }
    
    // Main Content
    Item {
        anchors.top: topSliver.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        
        Media.MediaInfo {
            id: mediaInfo
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            
            islandState: root.islandState
            mprisPlayer: root.mprisPlayer
            theme: root.theme
        }
        
        Media.MediaControls {
            id: mediaControls
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            
            islandState: root.islandState
            mprisPlayer: root.mprisPlayer
            theme: root.theme
            
            onPreviousClicked: {
                if (root.mprisPlayer && root.canSendMpris()) {
                    var threshold = root.mprisPlayer.length > 10000 ? 3000000 : 3;
                    if (root.mprisPlayer.position > threshold && root.mprisPlayer.canSeek) {
                        root.mprisPlayer.position = 0;
                    } else {
                        root.isSwitchingTracks = true;
                        trackSwitchTimeout.restart();
                        root.mprisPlayer.previous();
                    }
                }
            }
            onPlayPauseClicked: {
                if (root.mprisPlayer && root.canSendMpris()) {
                    root.mprisPlayer.togglePlaying();
                }
            }
            onNextClicked: {
                if (root.mprisPlayer && root.canSendMpris()) {
                    root.isSwitchingTracks = true;
                    trackSwitchTimeout.restart();
                    root.mprisPlayer.next();
                }
            }
        }
        
        Media.MediaProgressBar {
            id: progressBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 4
            
            islandState: root.islandState
            mprisPlayer: root.mprisPlayer
            theme: root.theme
        }
    }
}
