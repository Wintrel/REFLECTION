import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/about" as About

// About category stage — watermark text + editorial ambient
CategoryStage {
    id: root
    categoryTitle: "About"
    categorySubtitle: "System information & credits"

    signal secretUnlocked()

    pageContent: Item {
        About.AboutSettings {
            anchors.fill: parent
            theme: root.theme
            onSecretUnlocked: root.secretUnlocked()
        }
    }
}
