import "../../../../core/state" as State
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
    
    property bool isExpanded: root.islandState === State.IslandState.expanded
    opacity: isExpanded ? 1 : 0
    visible: opacity > 0
    scale: isExpanded ? 1.0 : 0.94
    layer.enabled: true
    Behavior on opacity { 
        NumberAnimation { 
            duration: root.isExpanded ? (root.theme ? root.theme.durationContentIn : 220) : (root.theme ? root.theme.durationContentOut : 120)
            easing.type: root.isExpanded ? Easing.OutQuad : Easing.InQuad 
        } 
    }
    // Background click/drag handlers that don't block UI buttons
    TapHandler {
        onTapped: {
            if (typeof islandWidget !== "undefined") {
                islandWidget.islandState = State.IslandState.idle;
            }
        }
    }

    DragHandler {
        target: null
        xAxis.enabled: true
        yAxis.enabled: true
        onActiveChanged: {
            if (!active) {
                var dx = translation.x;
                var dy = translation.y;
                var absX = Math.abs(dx);
                var absY = Math.abs(dy);
                
                if (absX > absY && absX > 35) {
                    if (dx > 0) {
                        // Swipe Right -> Notification History
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.notificationHistory;
                        }
                    } else {
                        // Swipe Left -> Battery / System Monitor
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.battery;
                        }
                    }
                } else if (absY > absX && absY > 30) {
                    if (dy > 0) {
                        // Swipe Down -> Cider Hub (Extended)
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.ciderExpanded;
                        }
                    } else {
                        // Swipe Up -> Collapse to Pill
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.idle;
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: spatialGestureArea
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.NoButton
        
        property real accumulatedX: 0
        property real accumulatedY: 0
        property real lastWheelEventTime: 0
        property real lastGestureActionTime: 0
        
        onWheel: function(wheel) {
            var now = Date.now();
            
            // Cooldown after triggering an action
            if (now - lastGestureActionTime < 400) {
                lastWheelEventTime = now;
                return;
            }
            
            // If it's been a while since the last event, reset accumulators
            if (now - lastWheelEventTime > 250) {
                accumulatedX = 0;
                accumulatedY = 0;
            }
            lastWheelEventTime = now;
            
            var dx = wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : wheel.angleDelta.x;
            var dy = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : wheel.angleDelta.y;
            
            accumulatedX += dx;
            accumulatedY += dy;
            
            var absX = Math.abs(accumulatedX);
            var absY = Math.abs(accumulatedY);
            var threshold = 60; // Enough for a single scroll wheel click (120) or a short trackpad swipe
            
            if (absX > absY && absX > threshold) {
                lastGestureActionTime = now;
                if (accumulatedX > 0) {
                    // Two-finger trackpad swipe right -> Notification History
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.notificationHistory;
                    }
                } else {
                    // Two-finger trackpad swipe left -> Battery / System Monitor
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.battery;
                    }
                }
                accumulatedX = 0;
                accumulatedY = 0;
            } else if (absY > absX && absY > threshold) {
                lastGestureActionTime = now;
                if (accumulatedY > 0) {
                    // Two-finger trackpad swipe down -> Cider Hub (Extended)
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.ciderExpanded;
                    }
                } else {
                    // Two-finger trackpad swipe up -> Collapse to Pill
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.idle;
                    }
                }
                accumulatedX = 0;
                accumulatedY = 0;
            }
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: root.theme ? root.theme.durationMorph : 360
            easing.type: Easing.OutCubic
        }
    }
    
    Media.MediaBackground {
        anchors.fill: parent
        islandState: root.islandState
        mprisPlayer: root.mprisPlayer
        theme: root.theme
        isSwitchingTracks: root.isSwitchingTracks
    }
    
    IslandTopBar {
        id: topSliver
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        islandState: root.islandState
        mprisPlayer: root.mprisPlayer
        theme: root.theme
        title: "Now Playing"
        showBatteryPill: true
        showCiderExpandButton: true
        showCloseButton: true
    }
    
    // Media Zone (info + controls, centered above progress bar)
    Item {
        anchors.top: topSliver.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: progressBar.top
        anchors.bottomMargin: 2
        
        Media.MediaInfo {
            id: mediaInfo
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
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
    }
    
    Media.MediaProgressBar {
        id: progressBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 2
        
        islandState: root.islandState
        mprisPlayer: root.mprisPlayer
        theme: root.theme
    }
}
