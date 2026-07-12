import QtQuick
import Qt5Compat.GraphicalEffects
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

    // CENTRALIZED CONTROLLERS
    // These replace the 137+ individual connections and timers that were crashing performance.

    Connections {
        target: CavaService
        function onValuesChanged() {
            if (root.isPlaying && root.hasCava) {
                var cavaLen = CavaService.values.length;
                if (cavaLen === 0) return;
                
                var count = root.barCount;
                var h = root.height * 0.9;
                
                for (var i = 0; i < count; i++) {
                    var item = visualizerRepeater.itemAt(i);
                    if (item) {
                        var cavaIndex = Math.min(Math.floor(i * cavaLen / Math.max(1, count)), cavaLen - 1);
                        item.targetHeight = Math.max(5, CavaService.values[cavaIndex] * h);
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onIsPlayingChanged() {
            if (!root.isPlaying) {
                var count = root.barCount;
                for (var i = 0; i < count; i++) {
                    var item = visualizerRepeater.itemAt(i);
                    if (item && item.targetHeight > 20) {
                        item.targetHeight = 5 + Math.random() * 5;
                    }
                }
            }
        }
    }

    Timer {
        id: mockPlayTimer
        property int tickCount: 0
        running: root.isPlaying && root.visible && !root.hasCava
        repeat: true
        interval: 30
        onTriggered: {
            var count = root.barCount;
            var group = tickCount % 5;
            for (var i = 0; i < count; i++) {
                if (i % 5 === group) {
                    var item = visualizerRepeater.itemAt(i);
                    if (item) {
                        item.targetHeight = Math.max(5, Math.random() * root.height * 0.8);
                    }
                }
            }
            tickCount++;
        }
    }

    Timer {
        id: mockIdleTimer
        property int tickCount: 0
        running: !root.isPlaying && root.visible
        repeat: true
        interval: 400
        onTriggered: {
            var count = root.barCount;
            var group = tickCount % 4;
            for (var i = 0; i < count; i++) {
                if (i % 4 === group) {
                    var item = visualizerRepeater.itemAt(i);
                    if (item) {
                        item.targetHeight = 5 + Math.random() * 12;
                    }
                }
            }
            tickCount++;
        }
    }
    
    Row {
        id: barRow
        anchors.fill: parent
        spacing: 6
        
        Repeater {
            id: visualizerRepeater
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

                property color barColor: {
                    if (root.isPlaying) {
                        return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4);
                    } else {
                        var baseAlpha = 0.08;
                        var highlightAlpha = 0.4;
                        var currentAlpha = baseAlpha + (highlightAlpha - baseAlpha) * barItem.glowFactor;
                        return Qt.rgba(1, 1, 1, currentAlpha);
                    }
                }
                
                Behavior on barColor { 
                    enabled: root.isPlaying
                    ColorAnimation { duration: 500 } 
                }

                // The Aurora Light Beam (Optimized Native Gradient)
                Rectangle {
                    width: parent.width
                    height: barItem.targetHeight
                    anchors.bottom: parent.bottom
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: barItem.barColor } // bottom
                    }
                }
                
                // The Floating Star Cap
                property real capHeight: targetHeight
                Behavior on capHeight {
                    enabled: !root.hasCava || !root.isPlaying
                    NumberAnimation {
                        // Fast up, slow float down for idle/mock states
                        duration: barItem.targetHeight > barItem.capHeight ? 100 : 800
                        easing.type: barItem.targetHeight > barItem.capHeight ? Easing.OutQuad : Easing.OutBounce
                    }
                }
                
                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: barItem.height - barItem.capHeight - 6 // Sit slightly above the beam
                    
                    // Make the cap fully opaque and slightly brighter for contrast
                    color: root.isPlaying ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 1.0) : Qt.rgba(1, 1, 1, 0.8)
                    opacity: barItem.capHeight > 8 ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                Behavior on targetHeight {
                    enabled: !root.hasCava || !root.isPlaying
                    NumberAnimation {
                        duration: root.isPlaying ? 150 : (1500 + (index % 3) * 500)
                        easing.type: root.isPlaying ? Easing.OutQuad : Easing.InOutSine
                    }
                }
            }
        }
    }
}
