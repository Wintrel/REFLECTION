import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var theme
    property string title: ""
    // We expect a model and a delegate to be passed in by the instantiator
    property alias model: listView.model
    property alias delegate: listView.delegate
    signal backClicked()

    anchors.fill: parent

    Column {
        anchors.fill: parent
        spacing: 16

        // Header
        Row {
            width: parent.width
            height: 48
            spacing: 16
            
            property bool isVisible: root.opacity > 0
            opacity: isVisible ? 1 : 0
            transform: Translate {
                y: isVisible ? 0 : -10
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            // Back Button
            Rectangle {
                width: 48
                height: 48
                radius: 12
                color: ma.pressed ? Qt.rgba(0,0,0,0.2) : (ma.containsMouse ? Qt.rgba(255,255,255,0.05) : "transparent")
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "arrow_back"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backClicked()
                }
            }

            // Title
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.title
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 18
                font.bold: true
                color: root.theme ? root.theme.textMain : "#FFF"
            }
        }

        // List Content
        ListView {
            id: listView
            width: parent.width
            height: parent.height - 64
            clip: true
            spacing: 8
            
            property bool isVisible: root.opacity > 0
            opacity: isVisible ? 1 : 0
            transform: Translate {
                y: isVisible ? 0 : 15
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
        }
    }
}
