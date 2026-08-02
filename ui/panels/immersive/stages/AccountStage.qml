import QtQuick
import QtQuick.Layouts
import "../../../../core/services/system"
import "../../dynamic_island/components" as Components

// Account category stage
CategoryStage {
    id: root
    categoryTitle: "Account"
    categorySubtitle: "Profile & account details"

    ambientContent: Item {
        // Left accent radial wash
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: root.theme ?
                        Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.07) :
                        Qt.rgba(0.3, 0.3, 0.7, 0.07)
                }
                GradientStop { position: 0.6; color: "transparent" }
            }
        }
    }

    pageContent: Item {
        Components.AccountSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
