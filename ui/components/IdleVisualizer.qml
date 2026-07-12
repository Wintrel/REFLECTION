import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    clip: true
    
    // Ambient Shimmer Sweep state
    property bool useGlobalSweep: false
    property real globalSweepPos: 0
    property real idleSweepPos: useGlobalSweep ? globalSweepPos : internalSweepPos
    
    property real internalSweepPos: 0
    SequentialAnimation on internalSweepPos {
        loops: Animation.Infinite
        running: root.visible && !root.useGlobalSweep
        NumberAnimation { from: -0.2; to: 1.2; duration: 10000; easing.type: Easing.InOutSine }
        PauseAnimation { duration: 1500 }
    }
    
    property real globalOffsetX: 0
    property real globalTotalWidth: root.width
    
    property int barCount: Math.max(0, Math.floor((root.width + 6) / 14))

    // CENTRALIZED CONTROLLER
    Timer {
        id: idleTimer
        property int tickCount: 0
        running: root.visible
        repeat: true
        interval: 400
        onTriggered: {
            var count = root.barCount;
            var group = tickCount % 4;
            for (var i = 0; i < count; i++) {
                if (i % 4 === group) {
                    var item = visualizerRepeater.itemAt(i);
                    if (item) {
                        item.targetHeight = 10 + Math.random() * 20;
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
                property real absoluteX: root.globalOffsetX + (localRelativeX * root.width)
                property real globalRelativeX: root.globalTotalWidth > 0 ? (absoluteX / root.globalTotalWidth) : 0
                
                property real distToSweep: Math.abs(globalRelativeX - root.idleSweepPos)
                
                // Fixed glow width in global normalized coords
                property real glowRadius: 0.12
                property real glowFactor: Math.max(0, 1.0 - (distToSweep / glowRadius))

                property color barColor: {
                    var base = Qt.rgba(1, 1, 1, 0.08);
                    var highlight = Qt.rgba(0.78, 0.79, 0.81, 0.6); // Electric Blue shimmer
                    var glow = barItem.glowFactor;
                    
                    var r = base.r * (1 - glow) + highlight.r * glow;
                    var g = base.g * (1 - glow) + highlight.g * glow;
                    var b = base.b * (1 - glow) + highlight.b * glow;
                    var a = base.a * (1 - glow) + highlight.a * glow;
                    
                    return Qt.rgba(r, g, b, a);
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
                    NumberAnimation {
                        // Fast up, slow float down
                        duration: barItem.targetHeight > barItem.capHeight ? 300 : 1800
                        easing.type: barItem.targetHeight > barItem.capHeight ? Easing.OutQuad : Easing.OutBounce
                    }
                }
                
                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: barItem.height - barItem.capHeight - 6 // Sit slightly above the beam
                    color: barItem.barColor
                    opacity: barItem.capHeight > 8 ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                Behavior on targetHeight {
                    NumberAnimation {
                        duration: 1500 + (index % 3) * 500
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}
