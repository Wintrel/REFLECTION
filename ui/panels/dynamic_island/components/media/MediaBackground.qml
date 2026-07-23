import "core/state" as State
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../components" as Components

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null
    property bool isSwitchingTracks: false

    // Starfield Voidy
    Components.Starfield {
        id: voidStarfield
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
        isPlaying: root.islandState === State.IslandState.expanded && (root.mprisPlayer ? root.mprisPlayer.isPlaying : false)
        accentColor: root.isSwitchingTracks ? "#11111b" : (root.theme ? root.theme.accentMusic : "#5611f8")
        Behavior on accentColor { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }
    
    // Electric Blue Loading Shimmer Overlay (Masked to Visualizer Bars)
    Item {
        anchors.fill: bgVisualizer
        visible: root.isSwitchingTracks
        
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: bgVisualizer
        }
        
        Rectangle {
            id: loadingShimmer
            width: parent.width * 0.8
            height: parent.height * 1.5
            y: -parent.height * 0.25
            rotation: 15
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { 
                    position: 0.5; 
                    color: root.theme ? Qt.rgba(root.theme.colorSystemShimmer.r, root.theme.colorSystemShimmer.g, root.theme.colorSystemShimmer.b, 0.9) : Qt.rgba(0, 1, 1, 0.9) 
                } // Bright electric blue from theme
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            SequentialAnimation on x {
                loops: Animation.Infinite
                running: root.isSwitchingTracks && root.visible
                NumberAnimation { from: -loadingShimmer.width - 20; to: bgVisualizer.width + 50; duration: 1200; easing.type: Easing.InOutSine }
                PauseAnimation { duration: 100 }
            }
        }
    }
}
