import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/updates" as Updates

// Updates category stage — sweeping horizontal scan line ambient
CategoryStage {
    id: root
    categoryTitle: "Updates"
    categorySubtitle: "System & Reflection updates"


    pageContent: Item {
        Updates.UpdatesSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
