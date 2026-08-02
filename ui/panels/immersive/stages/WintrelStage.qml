import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/about" as About

// Wintrel (secret) stage — matrix green column ambient
CategoryStage {
    id: root
    categoryTitle: "Wintrel"
    categorySubtitle: "Secret terminal environment"

    ambientContent: Item {
        // Matrix-style vertical column gradients
        Repeater {
            model: 18
            delegate: Rectangle {
                required property int index
                x: (parent.width / 18) * index
                width: 2
                height: parent.height
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(0.0, 0.9, 0.3, 0.06) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    pageContent: Item {
        About.WintrelSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
