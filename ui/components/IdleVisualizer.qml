import QtQuick

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
                property real absoluteX: root.globalOffsetX + (localRelativeX * root.width)
                property real globalRelativeX: root.globalTotalWidth > 0 ? (absoluteX / root.globalTotalWidth) : 0
                
                property real distToSweep: Math.abs(globalRelativeX - root.idleSweepPos)
                
                // Fixed glow width in global normalized coords — consistent across all monitors
                // so the shimmer doesn't shrink/grow when crossing the monitor boundary
                property real glowRadius: 0.12
                property real glowFactor: Math.max(0, 1.0 - (distToSweep / glowRadius))

                Rectangle {
                    width: parent.width
                    height: barItem.targetHeight
                    anchors.bottom: parent.bottom
                    radius: 4

                    color: {
                        var base = Qt.rgba(1, 1, 1, 0.08);
                        var highlight = Qt.rgba(0.2, 0.6, 1.0, 0.6); // Electric Blue shimmer
                        var glow = barItem.glowFactor;
                        
                        var r = base.r * (1 - glow) + highlight.r * glow;
                        var g = base.g * (1 - glow) + highlight.g * glow;
                        var b = base.b * (1 - glow) + highlight.b * glow;
                        var a = base.a * (1 - glow) + highlight.a * glow;
                        
                        return Qt.rgba(r, g, b, a);
                    }
                }

                Behavior on targetHeight {
                    NumberAnimation {
                        duration: 1500 + (index % 3) * 500
                        easing.type: Easing.InOutSine
                    }
                }
                
                Timer {
                    running: root.visible
                    repeat: true
                    interval: 1500 + (index % 4) * 400
                    onTriggered: {
                        barItem.targetHeight = 10 + Math.random() * 20
                    }
                }
            }
        }
    }
}
