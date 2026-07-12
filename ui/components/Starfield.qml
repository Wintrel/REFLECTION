import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // Amount of stars in the void
    property int starCount: 40

    // Base color of the stars
    property color starColor: "#ffffff"

    clip: true

    Repeater {
        model: root.starCount

        Item {
            id: starWrapper

            // Generate random constants ONCE so they don't re-evaluate on resize
            property real randX:      Math.random()
            property real randY:      Math.random()

            // Vertical drift
            property real driftDistY: 3 + Math.random() * 8
            property int  driftTimeY: 15000 + Math.random() * 10000

            // Horizontal drift — slower and shorter so it reads as depth, not movement
            property real driftDistX: 2 + Math.random() * 5
            property int  driftTimeX: 20000 + Math.random() * 15000

            property int  pauseTime:  Math.random() * 4000

            // Bind to the parent's size using the stable random percentages
            x: randX * root.width
            y: randY * root.height

            // Randomize size between 1.0 and 2.5 pixels
            property real size: 1.0 + Math.random() * 2.5
            width:  size
            height: size

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.starColor
                opacity: 0.2

                SequentialAnimation on opacity {
                    loops:   Animation.Infinite
                    running: root.visible

                    PauseAnimation { duration: Math.random() * 2000 }

                    NumberAnimation {
                        from: 0.15
                        to:   0.4 + Math.random() * 0.5
                        duration: 2000 + Math.random() * 3000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: 0.4 + Math.random() * 0.5
                        to:   0.15
                        duration: 2000 + Math.random() * 3000
                        easing.type: Easing.InOutSine
                    }
                    PauseAnimation { duration: 500 + Math.random() * 1500 }
                }
            }

            // Two-axis drift via a single Translate transform
            transform: Translate {
                id: drift

                SequentialAnimation on y {
                    loops:   Animation.Infinite
                    running: root.visible

                    PauseAnimation { duration: starWrapper.pauseTime }
                    NumberAnimation {
                        from: 0
                        to:   -starWrapper.driftDistY
                        duration: starWrapper.driftTimeY
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: -starWrapper.driftDistY
                        to:   0
                        duration: starWrapper.driftTimeY
                        easing.type: Easing.InOutSine
                    }
                }

                // Horizontal drift — offset phase so it doesn't sync with Y
                SequentialAnimation on x {
                    loops:   Animation.Infinite
                    running: root.visible

                    PauseAnimation { duration: starWrapper.pauseTime + starWrapper.driftTimeY / 3 }
                    NumberAnimation {
                        from: 0
                        to:   starWrapper.driftDistX
                        duration: starWrapper.driftTimeX
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: starWrapper.driftDistX
                        to:   0
                        duration: starWrapper.driftTimeX
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}
