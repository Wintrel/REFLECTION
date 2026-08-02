import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // Amount of snowflakes (increased to maintain density in the massive 1500px column)
    property int starCount: 150

    // Base color
    property color starColor: "#ffffff"

    clip: true
    

    // Frosty colors for snow (white, deep purples, and icy blues for Midnight Winter)
    property var starColors: ["#ffffff", "#5151ad", "#0830b2", "#A5F3FC", "#818CF8", "#ffffff"]

    Repeater {
        model: root.starCount

        Item {
            id: starWrapper

            // Random initial placement (spread across the entire 1500px column)
            property real initialX: Math.random() * 2000 // Wide enough for any screen
            property real initialY: Math.random() * 1500

            // Fall speed (pixels per millisecond)
            property real fallSpeed: 0.02 + Math.random() * 0.04
            
            // Wind properties
            property real windSway: 15 + Math.random() * 30
            property real windSpeed: 3000 + Math.random() * 4000


            // Randomize size
            property real size: 1.5 + Math.random() * 3.5
            width:  size
            height: size

            // Snowflake
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.starColors[index % root.starColors.length]
                // Smaller flakes are more transparent (further away)
                opacity: size < 2.5 ? 0.3 + Math.random() * 0.3 : 0.6 + Math.random() * 0.4
            }

            x: initialX
            y: initialY

            // Fall Animation (GPU)
            SequentialAnimation on y {
                loops: Animation.Infinite
                running: root.visible

                // 1. Initial fall from random start position to bottom of the massive column
                NumberAnimation {
                    to: 1500
                    duration: (1500 - starWrapper.initialY) / starWrapper.fallSpeed
                }

                // 2. Snap to top
                PropertyAction { value: -20 }

                // 3. Full falls for the rest of eternity
                NumberAnimation {
                    to: 1500
                    duration: 1520 / starWrapper.fallSpeed
                }
            }

            // Wind Sway Animation (GPU)
            SequentialAnimation on x {
                loops: Animation.Infinite
                running: root.visible

                NumberAnimation {
                    from: starWrapper.initialX
                    to: starWrapper.initialX + starWrapper.windSway
                    duration: starWrapper.windSpeed
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    from: starWrapper.initialX + starWrapper.windSway
                    to: starWrapper.initialX - starWrapper.windSway
                    duration: starWrapper.windSpeed * 2
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    from: starWrapper.initialX - starWrapper.windSway
                    to: starWrapper.initialX
                    duration: starWrapper.windSpeed
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
