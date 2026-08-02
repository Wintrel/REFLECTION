import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    clip: true
    
    property int barCount: Math.max(0, Math.floor((root.width + 6) / 14))

    // Single sweep position drives all bar shimmers (replaces 137 per-bar animations)
    property real sweepPos: -0.1
    SequentialAnimation on sweepPos {
        loops: Animation.Infinite
        running: root.visible
        NumberAnimation { from: -0.1; to: 1.1; duration: 5000; easing.type: Easing.InOutSine }
        PauseAnimation { duration: 1500 }
    }

    // Single timer drives all bar height drift (replaces 137 per-bar Timers)
    Timer {
        running: root.visible
        repeat: true
        interval: 1800
        onTriggered: {
            var count = root.barCount;
            for (var i = 0; i < count; i++) {
                var item = visualizerRepeater.itemAt(i);
                if (!item) continue;
                if (Math.random() > 0.5) {
                    item.targetHeight = Math.random() * 5;
                } else {
                    item.targetHeight = 10 + Math.random() * 25;
                }
            }
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
                
                property real animatingHeight: targetHeight
                Behavior on animatingHeight {
                    NumberAnimation {
                        duration: 1500 + (index % 3) * 500
                        easing.type: Easing.InOutSine
                    }
                }
                
                property real localRelativeX: root.barCount > 1 ? (index / (root.barCount - 1)) : 0

                // The Aurora Light Beam Base
                Rectangle {
                    width: parent.width
                    height: barItem.animatingHeight
                    anchors.bottom: parent.bottom
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.08) } // bottom
                    }
                }

                // The Aurora Light Beam Shimmer Overlay
                Rectangle {
                    id: shimmerOverlay
                    width: parent.width
                    height: barItem.animatingHeight
                    anchors.bottom: parent.bottom
                    // Shimmer driven by single sweep position instead of per-bar animation
                    property real _shimmerVal: {
                        var dist = Math.abs(root.sweepPos - barItem.localRelativeX);
                        if (dist < 0.12) return 1.0 - (dist / 0.12);
                        return 0;
                    }
                    opacity: _shimmerVal
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.8) } // bottom (Brighter shimmer to be visible)
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
                    color: Qt.rgba(0.9, 0.9, 0.95, 0.9)
                    
                    // The star illuminates ONLY when the shimmer passes over it, and only if it's high enough!
                    // This perfectly synchronizes the stars with the sweep and eliminates OLED burn-in.
                    opacity: (barItem.capHeight > 8 ? 1.0 : 0.0) * shimmerOverlay.opacity
                }


            }
        }
    }
}
