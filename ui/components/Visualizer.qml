import QtQuick
import "../../core/services/media"

Item {
    id: root
    
    property bool isPlaying: true
    property color accentColor: "#A6E3A1" // theme.colorMusic fallback
    
    clip: true
    
    // Check if Cava is actually producing data
    property bool hasCava: CavaService.values && CavaService.values.length > 0
    
    // Automatically start the Cava process only when we actually need it
    Binding {
        target: CavaService
        property: "active"
        value: root.visible && root.isPlaying
        restoreMode: Binding.RestoreBindingOrValue
    }
    
    // Ambient Shimmer Sweep state for when music is paused
    property real idleSweepPos: 0
    SequentialAnimation on idleSweepPos {
        loops: Animation.Infinite
        running: !root.isPlaying && root.visible
        NumberAnimation { from: -0.2; to: 1.2; duration: 4000; easing.type: Easing.InOutSine }
        PauseAnimation { duration: 1500 }
    }
    
    property int barCount: Math.max(0, Math.floor((root.width + 6) / 14)) // 8px width + 6px spacing
    
    Row {
        id: barRow
        anchors.fill: parent
        spacing: 6
        
        Repeater {
            model: root.barCount

            Item {
                id: barItem
                width: 8
                height: barRow.height
                anchors.bottom: parent.bottom

                property real targetHeight: 5
                property real relativeX: root.barCount > 1 ? (index / (root.barCount - 1)) : 0
                property real distToSweep: Math.abs(relativeX - root.idleSweepPos)
                property real glowFactor: !root.isPlaying ? Math.max(0, 1.0 - (distToSweep / 0.15)) : 0

                Rectangle {
                    width: parent.width
                    height: barItem.targetHeight
                    anchors.bottom: parent.bottom
                    radius: 4

                    color: {
                        if (root.isPlaying) {
                            return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4);
                        } else {
                            // Dimmed base silver with a brighter ghostly highlight sweeping across
                            var baseAlpha = 0.08;
                            var highlightAlpha = 0.4;
                            var currentAlpha = baseAlpha + (highlightAlpha - baseAlpha) * barItem.glowFactor;
                            return Qt.rgba(1, 1, 1, currentAlpha);
                        }
                    }
                    
                    // Disable behavior when idle so the math-based glow can render smoothly frame-by-frame
                    Behavior on color { 
                        enabled: root.isPlaying
                        ColorAnimation { duration: 500 } 
                    }
                }

                Behavior on targetHeight {
                    NumberAnimation {
                        // Fast if Cava, slower for random fallback, very slow and smooth for idle
                        duration: root.isPlaying ? (root.hasCava ? 60 : 150) : (1500 + (index % 3) * 500)
                        easing.type: root.isPlaying ? Easing.OutQuad : Easing.InOutSine
                    }
                }
                
                // Cava integration
                Connections {
                    target: CavaService
                    function onValuesChanged() {
                        if (root.isPlaying && root.hasCava) {
                            var cavaLen = CavaService.values.length;
                            var cavaIndex = Math.min(Math.floor(index * cavaLen / Math.max(1, root.barCount)), cavaLen - 1);
                            var val = CavaService.values[cavaIndex];
                            barItem.targetHeight = Math.max(5, val * root.height * 0.9);
                        }
                    }
                }
                
                // Fallback random animation mimicking the music
                Timer {
                    running: root.isPlaying && root.visible && !root.hasCava
                    repeat: true
                    interval: 150 + (index % 5) * 30
                    onTriggered: {
                        barItem.targetHeight = Math.max(5, Math.random() * root.height * 0.8)
                    }
                }
                
                // Idle ambient floating animation
                Timer {
                    running: !root.isPlaying && root.visible
                    repeat: true
                    interval: 1500 + (index % 4) * 400
                    onTriggered: {
                        barItem.targetHeight = 5 + Math.random() * 12 // Drift slightly between 5 and 17px
                    }
                }
                
                // Initial drop when paused
                Connections {
                    target: root
                    function onIsPlayingChanged() {
                        if (!root.isPlaying && barItem.targetHeight > 20) {
                            barItem.targetHeight = 5 + Math.random() * 5;
                        }
                    }
                }
            }
        }
    }
}
