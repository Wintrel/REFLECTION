import QtQuick
import QtQuick.Layouts

// Behavior category stage — slow concentric rings ambient
CategoryStage {
    id: root
    categoryTitle: "Behavior"
    categorySubtitle: "Shell interaction & automation"

    ambientContent: Item {
        // Slow breathing concentric rings — pure Rectangle borders
        Repeater {
            model: 4
            delegate: Rectangle {
                required property int index
                property real baseSize: Math.min(parent.width, parent.height) * (0.25 + index * 0.18)
                anchors.centerIn: parent
                width: baseSize
                height: baseSize
                radius: baseSize / 2
                color: "transparent"
                border.width: 1
                border.color: root.theme ?
                    Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, Math.max(0.01, 0.06 - index * 0.01)) :
                    Qt.rgba(0.3, 0.3, 0.7, Math.max(0.01, 0.06 - index * 0.01))

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: root.isCurrentPage
                    PauseAnimation { duration: index * 600 }
                    NumberAnimation { to: 1.04; duration: 3000 + index * 400; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 3000 + index * 400; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    pageContent: Item {
        Text {
            anchors.centerIn: parent
            text: "Behavior settings coming soon"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            color: root.theme ? root.theme.textSub : "#888"
        }
    }
}
