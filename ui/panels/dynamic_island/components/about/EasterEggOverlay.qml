import QtQuick
import "../../../../components" as GlobalComponents

Item {
    id: root
    anchors.fill: parent

    function trigger() {
        fallingStars.active = true
        stopTimer.restart()
    }

    Timer {
        id: stopTimer
        interval: 4000
        onTriggered: fallingStars.active = false
    }

    GlobalComponents.FallingStars {
        id: fallingStars
        active: false
    }
}
