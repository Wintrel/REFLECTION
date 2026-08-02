import QtQuick
import QtQuick.Layouts
import "../../../../core/services/system"
import "../../dynamic_island/components" as Components

// Account category stage
CategoryStage {
    id: root
    categoryTitle: "Account"
    categorySubtitle: "Profile & account details"

    pageContent: Item {
        Components.AccountSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
