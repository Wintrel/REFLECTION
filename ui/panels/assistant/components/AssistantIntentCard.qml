import QtQuick
import QtQuick.Layouts

Rectangle {
    id: intentCard

    property var theme: null
    property string icon: ""
    property string title: ""
    property string detail: ""
    property string prompt: ""

    signal clicked()

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"
    readonly property color cardColor: theme ? theme.surfaceCard : "#111115"
    readonly property color raisedColor: theme ? theme.surfaceOverlay : "#1a1a22"

    implicitHeight: 72
    radius: 16
    color: intentMouse.containsMouse
        ? raisedColor
        : cardColor
    border.width: 0

    transform: Translate {
        x: intentMouse.containsMouse ? 3 : 0
        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    }

    Behavior on color { ColorAnimation { duration: 170 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 16
        spacing: 13

        Text {
            text: intentCard.icon
            font.family: intentCard.theme ? intentCard.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 22
            color: intentMouse.containsMouse ? intentCard.accent : intentCard.subText
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: intentCard.title
                elide: Text.ElideRight
                font.family: intentCard.theme ? intentCard.theme.fontMain : "Inter"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: intentCard.mainText
            }

            Text {
                Layout.fillWidth: true
                text: intentCard.detail
                elide: Text.ElideRight
                font.family: intentCard.theme ? intentCard.theme.fontMain : "Inter"
                font.pixelSize: 11
                color: intentCard.subText
            }
        }

        Text {
            text: "arrow_forward"
            font.family: intentCard.theme ? intentCard.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 18
            color: intentMouse.containsMouse ? intentCard.accent : intentCard.mutedText
        }
    }

    MouseArea {
        id: intentMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: intentCard.clicked()
    }
}
