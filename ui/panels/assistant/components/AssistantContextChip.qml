import QtQuick
import QtQuick.Layouts

Rectangle {
    id: contextChip

    property var theme: null
    property string icon: ""
    property string label: ""

    signal removed()

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"

    implicitWidth: chipRow.implicitWidth + 20
    implicitHeight: 30
    radius: 15
    color: Qt.rgba(accent.r, accent.g, accent.b, 0.12)
    border.width: 1
    border.color: Qt.rgba(accent.r, accent.g, accent.b, 0.22)

    RowLayout {
        id: chipRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: contextChip.icon
            font.family: contextChip.theme ? contextChip.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 15
            color: contextChip.accent
        }

        Text {
            text: contextChip.label
            font.family: contextChip.theme ? contextChip.theme.fontMain : "Inter"
            font.pixelSize: 11
            font.weight: Font.Medium
            color: contextChip.mainText
        }

        Text {
            text: "close"
            font.family: contextChip.theme ? contextChip.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 14
            color: contextChip.subText
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: contextChip.removed()
    }
}
