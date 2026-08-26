import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../../core" as Core
import "../../../../core/state" as State
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root

    property var theme: null
    property var targetWidget: null
    property var mprisPlayer: null
    property bool active: false
    property real popProgress: 0
    readonly property bool isHovered: ma.containsMouse

    signal expandRequested()

    width: theme ? theme.islandMinH : 45
    height: theme ? theme.islandMinH : 45

    // Physical emergence geometry to the LEFT:
    // When popProgress = 0, sits tucked completely inside/behind the island's left bezel.
    // When popProgress = 1, emerges fully into view -10px to the left of the island.
    x: targetWidget ? (targetWidget.x + 6 - (popProgress * (width + 16))) : 0
    y: targetWidget ? (targetWidget.y + (targetWidget.height - height) / 2) : 0

    opacity: Math.min(1.0, popProgress * 1.4)
    visible: popProgress > 0

    readonly property bool isPlaying: mprisPlayer && mprisPlayer.isPlaying

    onActiveChanged: {
        if (active) {
            retractAnim.stop();
            popAnim.restart();
        } else {
            popAnim.stop();
            retractAnim.restart();
        }
    }

    // Ejection Pop-out Animation to the left with droplet momentum
    ParallelAnimation {
        id: popAnim

        // Horizontal slide out to the left
        NumberAnimation {
            target: root
            property: "popProgress"
            from: 0.0
            to: 1.0
            duration: root.theme ? root.theme.durationMorph : 360
            easing.type: root.theme ? root.theme.easingMorph : Easing.OutBack
            easing.overshoot: root.theme ? root.theme.morphOvershoot : 0.35
        }

        // Droplet stretch X (stretches as it emerges leftward, snaps back on detach)
        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                from: 0.75
                to: 1.18
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                to: 1.0
                duration: 210
                easing.type: Easing.OutBack
                easing.overshoot: 0.4
            }
        }

        // Droplet compress Y (fluid volume preservation)
        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                from: 0.85
                to: 0.90
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                to: 1.0
                duration: 210
                easing.type: Easing.OutBack
                easing.overshoot: 0.4
            }
        }
    }

    // Ingest & Absorption Retract Animation to the right (back into the island)
    ParallelAnimation {
        id: retractAnim

        NumberAnimation {
            target: root
            property: "popProgress"
            to: 0.0
            duration: 260
            easing.type: Easing.InCubic
        }

        // Stretch toward the right (toward the island) as it gets pulled in
        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                to: 1.14
                duration: 120
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "xScale"
                to: 0.70
                duration: 140
                easing.type: Easing.InQuad
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                to: 0.88
                duration: 120
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropletScale
                property: "yScale"
                to: 0.75
                duration: 140
                easing.type: Easing.InQuad
            }
        }
    }

    // Outer Glow / Music Accent Aura
    RectangularGlow {
        anchors.fill: orbBackground
        glowRadius: 14
        spread: 0.08
        color: root.theme ? root.theme.accentMusic : "#7C9CFF"
        cornerRadius: orbBackground.radius + glowRadius
        opacity: Math.max(0, (root.popProgress - 0.2) / 0.8) * (root.isHovered ? 0.60 : 0.35)

        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on color { ColorAnimation { duration: 300 } }
    }

    // Orb Circular Container
    Rectangle {
        id: orbBackground
        anchors.fill: parent
        radius: height / 2
        color: root.theme ? root.theme.bgBezel : "#000000"

        transform: Scale {
            id: dropletScale
            origin.x: orbBackground.width // anchored to right edge as it ejects leftward
            origin.y: orbBackground.height / 2
            xScale: 1.0
            yScale: 1.0
        }

        border.width: root.theme && root.theme.islandBorderWidth > 0 ? 1 : 0
        border.color: root.theme ? Qt.rgba(root.theme.accentMusic.r, root.theme.accentMusic.g, root.theme.accentMusic.b, 0.55) : Qt.rgba(0.48, 0.61, 1.0, 0.55)

        // Subtle press & hover scale
        scale: ma.pressed ? 0.95 : (root.isHovered ? 1.05 : 1.0)
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

        // Inner Void Glass Inset
        Rectangle {
            anchors.fill: parent
            anchors.margins: root.theme ? root.theme.islandBorderWidth : 1
            radius: Math.max(0, parent.radius - 1)
            color: root.theme ? root.theme.bgInner : "#0A0A0E"
            clip: true

            // Mini Starfield
            Components.Starfield {
                anchors.fill: parent
                starCount: 5
                starColor: root.theme ? root.theme.accentMusic : "#7C9CFF"
                opacity: 0.35
            }

            // 3-Bar Equalizer Waveform
            Item {
                anchors.centerIn: parent
                width: 18
                height: 18

                Row {
                    anchors.centerIn: parent
                    spacing: 3

                    Repeater {
                        model: 3
                        Rectangle {
                            width: 3
                            radius: 1.5
                            color: root.theme ? root.theme.accentMusic : "#7C9CFF"
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation on height {
                                loops: Animation.Infinite
                                running: root.isPlaying && root.active
                                NumberAnimation {
                                    from: 4; to: [14, 8, 16][index];
                                    duration: [300, 250, 350][index];
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    from: [14, 8, 16][index]; to: 4;
                                    duration: [300, 250, 350][index];
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            // Flatten to 4px dot when paused
                            height: root.isPlaying ? 8 : 3
                            Behavior on height { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }

        // Interactive Click & Hover Area
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.expandRequested();
                } else {
                    if (root.mprisPlayer) {
                        root.mprisPlayer.togglePlaying();
                    }
                }
            }

            onDoubleClicked: {
                root.expandRequested();
            }
        }
    }
}

