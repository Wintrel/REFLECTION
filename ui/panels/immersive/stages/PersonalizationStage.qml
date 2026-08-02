import QtQuick
import QtQuick.Layouts
import "../../../../core/services/system"
import "../../dynamic_island/components/personalization" as Personalization

// Personalization category stage — live wallpaper ambient
CategoryStage {
    id: root
    categoryTitle: "Personalization"
    categorySubtitle: "Themes, wallpaper & effects"


    pageContent: Item {
        Personalization.PersonalizationSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
