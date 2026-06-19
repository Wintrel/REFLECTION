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
    
    Row {
        id: barRow
        anchors.fill: parent
        spacing: 6
        
        // Calculate how many bars can fit
        Repeater {
            model: Math.max(0, Math.floor((root.width + barRow.spacing) / (8 + barRow.spacing)))

            Item {
                id: barItem
                width: 8
                height: barRow.height
                anchors.bottom: parent.bottom

                property real targetHeight: 5

                Rectangle {
                    width: parent.width
                    height: barItem.targetHeight
                    anchors.bottom: parent.bottom
                    radius: 4

                    // slightly transparent accent color for background visualizer
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4)
                }

                Behavior on targetHeight {
                    NumberAnimation {
                        // Fast if Cava, slower for random fallback
                        duration: root.hasCava ? 60 : (root.isPlaying ? 150 : 400)
                        easing.type: root.isPlaying ? Easing.OutQuad : Easing.OutCubic
                    }
                }
                
                // Cava integration
                Connections {
                    target: CavaService
                    function onValuesChanged() {
                        if (root.isPlaying && root.hasCava) {
                            var cavaLen = CavaService.values.length;
                            // Find how many bars the repeater generated
                            var barCount = Math.max(1, barRow.children.length - 1); 
                            // Map this bar's index to the nearest Cava value index
                            var cavaIndex = Math.min(Math.floor(index * cavaLen / barCount), cavaLen - 1);
                            var val = CavaService.values[cavaIndex];
                            
                            barItem.targetHeight = Math.max(5, val * root.height * 0.9);
                        }
                    }
                }
                
                // Fallback random animation mimicking the music
                Timer {
                    running: root.isPlaying && root.visible && !root.hasCava
                    repeat: true
                    // Random interval so bars don't bounce together
                    interval: 150 + Math.random() * 150
                    onTriggered: {
                        barItem.targetHeight = Math.max(5, Math.random() * root.height * 0.8)
                    }
                }
                
                onTargetHeightChanged: {
                    if (!root.isPlaying) barItem.targetHeight = 5
                }
            }
        }
    }
}
