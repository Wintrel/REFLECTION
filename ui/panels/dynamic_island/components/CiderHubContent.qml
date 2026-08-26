import "../../../../core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/services/system"
import "../../../components" as Components
import "cider" as Cider

Item {
    id: root
    
    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null
    property real islandCiderW: 800
    property real islandCiderH: 550
    
    property int currentTab: 0 // 0: Queue, 1: Search, 2: Lyrics.
    
    width: islandCiderW - 32
    height: islandCiderH - 32
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: (islandCiderH - height) / 2
    
    property bool isCider: root.islandState === State.IslandState.ciderExpanded
    opacity: isCider ? 1 : 0
    visible: opacity > 0
    scale: isCider ? 1.0 : 0.95
    layer.enabled: true
    Behavior on opacity { 
        NumberAnimation { 
            duration: root.isCider ? (root.theme ? root.theme.durationContentIn : 220) : (root.theme ? root.theme.durationContentOut : 120)
            easing.type: root.isCider ? Easing.OutQuad : Easing.InQuad 
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
                
                if (absY > absX && absY > 30) {
                    if (dy < 0) {
                        // Swipe Up -> Return to Expanded Media
                        if (typeof islandWidget !== "undefined") {
                            islandWidget.islandState = State.IslandState.expanded;
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
        
        property real lastWheelGestureTime: 0
        
        onWheel: function(wheel) {
            var now = Date.now();
            if (now - lastWheelGestureTime < 320) return;
            
            var dy = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : wheel.angleDelta.y;
            var absY = Math.abs(dy);
            var absX = Math.abs(wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : wheel.angleDelta.x);
            
            if (absY > absX && absY > 25) {
                if (dy < 0) {
                    lastWheelGestureTime = now;
                    // Two-finger trackpad swipe up -> Return to Expanded Media
                    if (typeof islandWidget !== "undefined") {
                        islandWidget.islandState = State.IslandState.expanded;
                    }
                }
            }
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: root.theme ? root.theme.durationMorph : 360
            easing.type: Easing.OutCubic
        }
    }
    
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
        isPlaying: root.islandState === State.IslandState.ciderExpanded && (root.mprisPlayer ? root.mprisPlayer.isPlaying : false)
        accentColor: root.theme ? root.theme.accentMusic : "#5611f8"
    }

    // TOP AREA: Navigation
    Cider.CiderTopNav {
        id: topNav
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        theme: root.theme
        currentTab: root.currentTab
        
        opacity: (root.islandState === State.IslandState.ciderExpanded) ? 1 : 0
        transform: Translate {
            y: (root.islandState === State.IslandState.ciderExpanded) ? 0 : -5
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        
        onCloseClicked: {
            if (typeof islandWidget !== "undefined") {
                islandWidget.islandState = State.IslandState.expanded;
            }
        }
        onTabSelected: (index) => {
            root.currentTab = index;
        }
    }

    // MIDDLE AREA: Dynamic Content
    Item {
        id: middleArea
        anchors.top: topNav.bottom
        anchors.topMargin: 20
        anchors.bottom: bottomBar.top
        anchors.bottomMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        
        Cider.CiderQueue {
            anchors.fill: parent
            theme: root.theme
            mprisPlayer: root.mprisPlayer
            opacity: root.currentTab === 0 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        
        Cider.CiderPlaylists {
            anchors.fill: parent
            theme: root.theme
            mprisPlayer: root.mprisPlayer
            opacity: root.currentTab === 1 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        
        Cider.CiderForYou {
            anchors.fill: parent
            theme: root.theme
            mprisPlayer: root.mprisPlayer
            opacity: root.currentTab === 2 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        
        Cider.CiderSearch {
            anchors.fill: parent
            theme: root.theme
            mprisPlayer: root.mprisPlayer
            opacity: root.currentTab === 3 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        
        Cider.CiderLyrics {
            anchors.fill: parent
            theme: root.theme
            mprisPlayer: root.mprisPlayer
            opacity: root.currentTab === 4 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    // BOTTOM AREA: Media Player Controls
    Cider.CiderBottomBar {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        theme: root.theme
        mprisPlayer: root.mprisPlayer
        
        opacity: (root.islandState === State.IslandState.ciderExpanded) ? 1 : 0
        transform: Translate {
            y: (root.islandState === State.IslandState.ciderExpanded) ? 0 : 10
            Behavior on y { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
        }
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
    }
}
