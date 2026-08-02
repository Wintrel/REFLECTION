import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/audio" as Audio

// Audio category stage — animated waveform ambient
CategoryStage {
    id: root
    categoryTitle: "Audio"
    categorySubtitle: "Volume, devices & Cider"

    ambientContent: Item {
        // Animated waveform bars — pure Rectangle, NVIDIA-safe
        Item {
            anchors.fill: parent
            opacity: 0.07
            clip: true

            Repeater {
                model: 28
                delegate: Rectangle {
                    required property int index
                    property real targetH: 0

                    x: (parent.width / 28) * index
                    width: (parent.width / 28) - 3
                    radius: 3
                    color: root.theme ? root.theme.accentPrimary : "#5151AD"
                    y: (parent.height / 2) - (height / 2)
                    height: targetH

                    SequentialAnimation on targetH {
                        loops: Animation.Infinite
                        running: root.isCurrentPage
                        PauseAnimation { duration: (index * 137) % 800 }
                        NumberAnimation {
                            to: 20 + (Math.sin(index * 0.8) * 50 + 50)
                            duration: 1200 + (index * 53) % 700
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: 8 + (index % 5) * 6
                            duration: 900 + (index * 37) % 500
                            easing.type: Easing.InOutSine
                        }
                    }
                }
            }
        }

        // Subtle bottom accent gradient bleed
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.35
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop {
                    position: 1.0
                    color: root.theme ?
                        Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.05) :
                        Qt.rgba(0.3, 0.3, 0.7, 0.05)
                }
            }
        }
    }

    pageContent: Item {
        Audio.AudioSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
