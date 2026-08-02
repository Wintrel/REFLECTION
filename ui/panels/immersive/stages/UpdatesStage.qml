import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/updates" as Updates

// Updates category stage — sweeping horizontal scan line ambient
CategoryStage {
    id: root
    categoryTitle: "Updates"
    categorySubtitle: "System & Reflection updates"

    ambientContent: Item {
        // Sweeping scan line
        Rectangle {
            id: scanLine
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.theme ?
                Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.25) :
                Qt.rgba(0.3, 0.3, 0.7, 0.25)
            y: 0

            SequentialAnimation on y {
                loops: Animation.Infinite
                running: root.isCurrentPage
                NumberAnimation { from: 0; to: parent.parent.height; duration: 3500; easing.type: Easing.InOutSine }
                PauseAnimation { duration: 400 }
            }

            // Soft glow halo below the scan line
            Rectangle {
                anchors.top: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: root.theme ?
                            Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.06) :
                            Qt.rgba(0.3, 0.3, 0.7, 0.06)
                    }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    pageContent: Item {
        Updates.UpdatesSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
