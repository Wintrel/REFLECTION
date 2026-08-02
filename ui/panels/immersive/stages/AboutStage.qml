import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/about" as About

// About category stage — watermark text + editorial ambient
CategoryStage {
    id: root
    categoryTitle: "About"
    categorySubtitle: "System information & credits"

    signal secretUnlocked()

    ambientContent: Item {
        // Accent edge wash from the right side
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.5
            gradient: Gradient {
                orientation: Gradient.Horizontal
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
        About.AboutSettings {
            anchors.fill: parent
            theme: root.theme
            onSecretUnlocked: root.secretUnlocked()
        }
    }
}
