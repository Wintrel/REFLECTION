import QtQuick
import "../../core/services/media"

Item {
    id: root
    
    property bool isPlaying: true
    property color accentColor: '#afa1e3'
    property var colorPalette: []
    
    clip: true
    
    property bool hasCava: CavaService.values && CavaService.values.length > 0
    
    property bool _isActive: root.visible && root.isPlaying
    on_IsActiveChanged: {
        if (_isActive) {
            CavaService.request();
        } else {
            CavaService.release();
        }
    }
    
    Component.onCompleted: {
        if (_isActive) CavaService.request();
    }
    
    Component.onDestruction: {
        if (_isActive) CavaService.release();
    }
    
    property int barCount: Math.max(0, Math.floor((root.width + 6) / 14))

    // Single sweep position for shimmer when paused (replaces 137 per-bar animations)
    property real shimmerSweep: -0.1
    SequentialAnimation on shimmerSweep {
        loops: Animation.Infinite
        running: !root.isPlaying && root.visible
        NumberAnimation { from: -0.1; to: 1.1; duration: 5000; easing.type: Easing.InOutSine }
        PauseAnimation { duration: 1500 }
    }

    // Single mock drift timer (replaces 137 per-bar Timers when no CAVA)
    Timer {
        running: root.isPlaying && root.visible && !root.hasCava
        repeat: true
        interval: 180
        onTriggered: {
            var count = root.barCount;
            var h = root.height;
            for (var i = 0; i < count; i++) {
                var item = visualizerRepeater.itemAt(i);
                if (item) {
                    item.targetHeight = Math.max(5, Math.random() * h * 0.8);
                }
            }
        }
    }

    // Single idle drift timer (replaces 137 per-bar Timers when paused)
    Timer {
        running: !root.isPlaying && root.visible
        repeat: true
        interval: 1800
        onTriggered: {
            var count = root.barCount;
            var h = root.height;
            for (var i = 0; i < count; i++) {
                var item = visualizerRepeater.itemAt(i);
                if (item) {
                    item.targetHeight = 5 + Math.random() * (h * 0.12);
                }
            }
        }
    }

    // Centralized CAVA Listener (Fast Loop, avoids 137 * 60Hz signal handlers)
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
                    if (item) {
                        if (item.targetHeight > 20) {
                            item.targetHeight = 5 + Math.random() * (root.height * 0.03);
                        }
                    }
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
                        // Dynamically scale smoothness based on panel height so large panels don't jump frantically
                        duration: root.isPlaying ? (root.hasCava ? Math.max(100, root.height * 0.3) : 180) : (1500 + (index % 3) * 500)
                        easing.type: root.isPlaying ? Easing.OutQuad : Easing.InOutSine
                    }
                }
                
                property real localRelativeX: root.barCount > 1 ? (index / (root.barCount - 1)) : 0

                property color activeBarColor: root.colorPalette && root.colorPalette.length > 0 ? root.colorPalette[index % root.colorPalette.length] : root.accentColor

                // The Aurora Light Beam Base
                Rectangle {
                    id: baseRect
                    width: parent.width
                    height: barItem.animatingHeight
                    anchors.bottom: parent.bottom
                    
                    property color baseColor: root.isPlaying ? Qt.rgba(barItem.activeBarColor.r, barItem.activeBarColor.g, barItem.activeBarColor.b, 0.4) : Qt.rgba(1, 1, 1, 0.08)
                    Behavior on baseColor { ColorAnimation { duration: 500 } }
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: baseRect.baseColor } // bottom
                    }
                }

                // The Aurora Light Beam Shimmer Overlay
                Rectangle {
                    width: parent.width
                    height: barItem.animatingHeight
                    anchors.bottom: parent.bottom
                    // Shimmer driven by single sweep position instead of per-bar animation
                    property real _shimmerVal: {
                        if (root.isPlaying) return 0;
                        var dist = Math.abs(root.shimmerSweep - barItem.localRelativeX);
                        if (dist < 0.12) return 1.0 - (dist / 0.12);
                        return 0;
                    }
                    opacity: _shimmerVal
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" } // top
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.4) } // bottom
                    }
                }
                
                Rectangle {
                    id: capRect
                    width: 4
                    height: 4
                    radius: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: barItem.height - barItem.animatingHeight - 6 // Always sit nicely above the beam
                    
                    property color activeColor: Qt.rgba(barItem.activeBarColor.r, barItem.activeBarColor.g, barItem.activeBarColor.b, 1.0)
                    property color idleColor: Qt.rgba(1, 1, 1, 0.8)
                    color: root.isPlaying ? activeColor : idleColor
                    Behavior on color { ColorAnimation { duration: 500 } }
                    
                    opacity: barItem.animatingHeight > 8 ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }


                

            }
        }
    }
}
