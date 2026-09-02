import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../core" as Core
import "../../../core/services/media"
import "../../components" as Components
import "../dynamic_island/components/cider" as Cider

Item {
    id: root

    property var theme: null
    property int currentTab: 0 // 0: Queue, 1: Playlists, 2: For You, 3: Search, 4: Lyrics
    property var mprisPlayer: CiderService // Using CiderService singleton natively

    // Background Visualizer
    Components.MusicVisualizer {
        id: bgVisualizer
        anchors.fill: parent
        anchors.margins: -8
        isPlaying: root.mprisPlayer.isPlaying
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

        onCloseClicked: {
            State.GlobalStates.closeCiderStudioWorkspace();
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
        height: 84
        theme: root.theme
        mprisPlayer: root.mprisPlayer
    }
}
