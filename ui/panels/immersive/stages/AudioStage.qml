import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/audio" as Audio

// Audio category stage — animated waveform ambient
CategoryStage {
    id: root
    categoryTitle: "Audio"
    categorySubtitle: "Volume, devices & routing"


    pageContent: Item {
        Audio.AudioSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
