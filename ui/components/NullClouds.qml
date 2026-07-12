import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent
    clip: true

    Repeater {
        model: 3

        Item {
            id: cloudWrapper

            // Fixed base positions chosen once at creation — animations are
            // computed from these so each cloud always oscillates around its
            // own origin rather than drifting away indefinitely.
            readonly property real baseRelX: 0.15 + Math.random() * 0.7
            readonly property real baseRelY: 0.15 + Math.random() * 0.7
            readonly property real swingX:  0.10 + Math.random() * 0.10
            readonly property real swingY:  0.08 + Math.random() * 0.10
            readonly property int  periodX: 35000 + Math.floor(Math.random() * 20000)
            readonly property int  periodY: 38000 + Math.floor(Math.random() * 18000)

            property real relX: baseRelX
            property real relY: baseRelY

            width:  Math.min(root.width, root.height) * (0.55 + Math.random() * 0.25)
            height: width

            x: (relX * root.width)  - (width  / 2)
            y: (relY * root.height) - (height / 2)

            RadialGradient {
                anchors.fill: parent
                horizontalRadius: width / 2
                verticalRadius: height / 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.0, 0.0, 0.0, 0.4 + Math.random() * 0.2) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // X oscillates symmetrically around baseRelX
            SequentialAnimation on relX {
                loops:   Animation.Infinite
                running: root.visible

                NumberAnimation {
                    to:       Math.min(0.95, cloudWrapper.baseRelX + cloudWrapper.swingX)
                    duration: cloudWrapper.periodX / 2
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to:       Math.max(0.05, cloudWrapper.baseRelX - cloudWrapper.swingX)
                    duration: cloudWrapper.periodX / 2
                    easing.type: Easing.InOutSine
                }
            }

            // Y oscillates symmetrically around baseRelY, out of phase with X
            SequentialAnimation on relY {
                loops:   Animation.Infinite
                running: root.visible

                // start offset so X and Y don't peak together
                PauseAnimation { duration: cloudWrapper.periodY / 4 }

                NumberAnimation {
                    to:       Math.max(0.05, cloudWrapper.baseRelY - cloudWrapper.swingY)
                    duration: cloudWrapper.periodY / 2
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to:       Math.min(0.95, cloudWrapper.baseRelY + cloudWrapper.swingY)
                    duration: cloudWrapper.periodY / 2
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
