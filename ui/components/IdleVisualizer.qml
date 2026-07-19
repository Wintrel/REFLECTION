import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    clip: true
    
    property int barCount: Math.max(0, Math.floor((root.width + 6) / 14))


    
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
                    opacity: _shimmerVal
                    
                    property real _shimmerVal: 0
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.8) } // bottom (Brighter shimmer to be visible)
                    }

                    SequentialAnimation on _shimmerVal {
                        loops: Animation.Infinite
                        running: root.visible
                        
                        PropertyAction { value: 0 }
                        PauseAnimation { duration: (index / Math.max(1, root.barCount)) * 4000 }
                        NumberAnimation { from: 0; to: 1.0; duration: 500; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.0; to: 0; duration: 500; easing.type: Easing.InOutSine }
                        PauseAnimation { duration: 4000 - ((index / Math.max(1, root.barCount)) * 4000) + 1500 }
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

                // INDIVIDUAL TIMERS FOR MOCK DRIFT (Organic feel)
                Timer {
                    running: root.visible
                    repeat: true
                    // Randomize interval slightly so they drift naturally
                    interval: 1500 + (index % 4) * 400
                    onTriggered: {
                        // 50% chance to drop to 0 (hiding the star cap to prevent burn-in)
                        // 50% chance to spike up proportionally
                        if (Math.random() > 0.5) {
                            barItem.targetHeight = Math.random() * 5;
                        } else {
                            barItem.targetHeight = 10 + Math.random() * 25;
                        }
                    }
                }
            }
        }
    }
}
