import QtQuick
import QtQuick.Layouts
import "../../../../core/services/system"
import "../../dynamic_island/components/personalization" as Personalization

// Personalization category stage — live wallpaper ambient
CategoryStage {
    id: root
    categoryTitle: "Personalization"
    categorySubtitle: "Themes, wallpaper & effects"

    ambientContent: Item {
        // Live wallpaper as ambient wash
        Image {
            anchors.fill: parent
            source: WallpaperService.currentWallpaper
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: 0.09
        }

        // Accent gradient bleed from bottom
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.45
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop {
                    position: 1.0
                    color: root.theme ?
                        Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.08) :
                        Qt.rgba(0.3, 0.3, 0.7, 0.08)
                }
            }
        }
    }

    pageContent: Item {
        Personalization.PersonalizationSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
