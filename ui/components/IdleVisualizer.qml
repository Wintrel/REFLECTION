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
                property real localRelativeX: root.barCount > 1 ? (index / (root.barCount - 1)) : 0

                // The Aurora Light Beam Base
                Rectangle {
                    width: parent.width
                    height: barItem.targetHeight
                    anchors.bottom: parent.bottom
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.08) } // bottom
                    }
                }

                // The Aurora Light Beam Shimmer Overlay
                Rectangle {
                    width: parent.width
                    height: barItem.targetHeight
                    anchors.bottom: parent.bottom
                    opacity: 0
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: Qt.rgba(0.78, 0.79, 0.81, 0.6) } // bottom
                    }

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.visible
                        
                        PauseAnimation { duration: barItem.localRelativeX * 5000 }
                        NumberAnimation { from: 0; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.0; to: 0; duration: 600; easing.type: Easing.InOutSine }
                        PauseAnimation { duration: 5000 - (barItem.localRelativeX * 5000) + 1500 }
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
                    color: Qt.rgba(0.85, 0.86, 0.88, 0.8)
                    opacity: barItem.capHeight > 8 ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                Behavior on targetHeight {
                    NumberAnimation {
                        duration: 1500 + (index % 3) * 500
                        easing.type: Easing.InOutSine
                    }
                }
                
                // INDIVIDUAL TIMERS FOR MOCK DRIFT (Organic feel)
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
