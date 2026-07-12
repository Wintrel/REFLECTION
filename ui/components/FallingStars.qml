import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    property bool active: true

    // Pool of falling star items
    Repeater {
        id: pool
        model: 25
        
        Item {
            id: starItem
            property real startX: 0
            property real speedX: 0
            property real speedY: 4
            property real size: 1
            property real lifeSpan: 1000

            x: startX
            y: -150
            width: size
            height: speedY * 8 // Streak length proportional to speed
            opacity: 0

            // Angle the streak along the velocity vector
            rotation: -Math.atan2(speedX, speedY) * 180 / Math.PI

            // Streak Rectangle using native gradient
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" } // top is tail
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.85) } // bottom is head
                }
            }

            SequentialAnimation {
                id: fallAnim
                running: false
                
                NumberAnimation {
                    target: starItem
                    property: "opacity"
                    to: 1.0
                    duration: 150
                }
                
                ParallelAnimation {
                    NumberAnimation {
                        target: starItem
                        property: "y"
                        to: root.height + 150
                        duration: starItem.lifeSpan
                        easing.type: Easing.OutSine // slightly decelerate as they fall deep
                    }
                    NumberAnimation {
                        target: starItem
                        property: "x"
                        to: starItem.startX + starItem.speedX * (starItem.lifeSpan / 16)
                        duration: starItem.lifeSpan
                    }
                }
                
                NumberAnimation {
                    target: starItem
                    property: "opacity"
                    to: 0
                    duration: 300
                }
                
                ScriptAction {
                    script: {
                        starItem.y = -150
                        starItem.opacity = 0
                    }
                }
            }

            function trigger() {
                if (!fallAnim.running) {
                    starItem.startX = Math.random() * root.width;
                    starItem.speedY = 4 + Math.random() * 6; // approx px per frame
                    starItem.speedX = -0.8 + Math.random() * 1.6;
                    starItem.size = 0.8 + Math.random() * 1.4;
                    
                    // Time = distance / pixels_per_second
                    // speedY is per 16ms, so speedY * 62.5 is px per second
                    var distY = root.height + 300;
                    starItem.lifeSpan = (distY / (starItem.speedY * 62.5)) * 1000;
                    
                    starItem.x = starItem.startX;
                    starItem.y = -150;
                    fallAnim.start();
                    return true;
                }
                return false;
            }
        }
    }

    Timer {
        id: spawnTimer
        running: root.visible && root.active
        repeat: true
        interval: 2000

        onTriggered: {
            var count = Math.floor(1 + Math.random() * 5);
            var spawned = 0;
            for (var i = 0; i < pool.count && spawned < count; i++) {
                if (pool.itemAt(i).trigger()) {
                    spawned++;
                }
            }
            // randomise next spawn interval
            interval = 1800 + Math.random() * 3200;
        }
    }
}
