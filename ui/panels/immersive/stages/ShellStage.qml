import QtQuick
import QtQuick.Layouts

// Shell category stage — blinking cursor + code-line bars ambient
CategoryStage {
    id: root
    categoryTitle: "Shell"
    categorySubtitle: "Layout, components & features"

    ambientContent: Item {
        // Faint horizontal "code line" bars
        Column {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            spacing: 18
            opacity: 0.05

            Repeater {
                model: 9
                delegate: Rectangle {
                    required property int index
                    height: 2
                    radius: 1
                    width: [180, 120, 220, 90, 160, 200, 110, 240, 140][index % 9]
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
            }
        }

        // Blinking cursor rectangle
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -94
            width: 10
            height: 20
            radius: 2
            color: root.theme ? root.theme.accentPrimary : "#5151AD"
            opacity: 0.4

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.isCurrentPage
                NumberAnimation { to: 0.4; duration: 500 }
                NumberAnimation { to: 0.0; duration: 500 }
            }
        }
    }

    pageContent: Item {
        Text {
            anchors.centerIn: parent
            text: "Shell settings coming soon"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            color: root.theme ? root.theme.textSub : "#888"
        }
    }
}
