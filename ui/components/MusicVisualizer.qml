import QtQuick
import "../../core/services/media"

Item {
    id: root
    
    property bool isPlaying: true
    property color accentColor: "#A6E3A1"
    
    clip: true
    
    property bool hasCava: CavaService.values && CavaService.values.length > 0
    
    Binding {
        target: CavaService
        property: "active"
        value: root.visible && root.isPlaying
        restoreMode: Binding.RestoreBindingOrValue
    }
    
    property real internalSweepPos: 0
    SequentialAnimation on internalSweepPos {
        loops: Animation.Infinite
        running: !root.isPlaying && root.visible
        NumberAnimation { from: -0.2; to: 1.2; duration: 4000; easing.type: Easing.InOutSine }
        PauseAnimation { duration: 1500 }
    }
    
    property int barCount: Math.max(0, Math.floor((root.width + 6) / 14))
    
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
                property real localRelativeX: root.barCount > 1 ? (index / (root.barCount - 1)) : 0
                property real distToSweep: Math.abs(localRelativeX - root.internalSweepPos)
                property real glowRadius: 0.15
                property real glowFactor: !root.isPlaying ? Math.max(0, 1.0 - (distToSweep / Math.max(0.05, glowRadius))) : 0

                Rectangle {
                    width: parent.width
                    height: barItem.targetHeight
                    anchors.bottom: parent.bottom
                    radius: 4

                    color: {
                        if (root.isPlaying) {
                            return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4);
                        } else {
                            var baseAlpha = 0.08;
                            var highlightAlpha = 0.4;
                            var currentAlpha = baseAlpha + (highlightAlpha - baseAlpha) * barItem.glowFactor;
                            return Qt.rgba(1, 1, 1, currentAlpha);
                        }
                    }
                    
                    Behavior on color { 
                        enabled: root.isPlaying
                        ColorAnimation { duration: 500 } 
                    }
                }

                Behavior on targetHeight {
                    NumberAnimation {
                        duration: root.isPlaying ? (root.hasCava ? 60 : 150) : (1500 + (index % 3) * 500)
                        easing.type: root.isPlaying ? Easing.OutQuad : Easing.InOutSine
                    }
                }
                
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
                
                Timer {
                    running: root.isPlaying && root.visible && !root.hasCava
                    repeat: true
                    interval: 150 + (index % 5) * 30
                    onTriggered: {
                        barItem.targetHeight = Math.max(5, Math.random() * root.height * 0.8)
                    }
                }
                
                Connections {
                    target: root
                    function onIsPlayingChanged() {
                        if (!root.isPlaying && barItem.targetHeight > 20) {
                            barItem.targetHeight = 5 + Math.random() * 5;
                        }
                    }
                }
                
                Timer {
                    running: !root.isPlaying && root.visible
                    repeat: true
                    interval: 1500 + (index % 4) * 400
                    onTriggered: {
                        barItem.targetHeight = 5 + Math.random() * 12
                    }
                }
            }
        }
    }
}
