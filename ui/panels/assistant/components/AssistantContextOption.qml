import QtQuick
import QtQuick.Layouts

Rectangle {
    id: contextOption

    property var theme: null
    property string icon: ""
    property string title: ""
    property string detail: ""
    property bool checked: false

    signal toggled()

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color cardColor: theme ? theme.surfaceCard : "#111115"

    implicitHeight: 58
    radius: 14
    color: optionMouse.containsMouse ? cardColor : "transparent"
    border.width: checked ? 1 : 0
    border.color: checked
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.30)
        : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: 11
            color: contextOption.checked
                ? Qt.rgba(contextOption.accent.r, contextOption.accent.g, contextOption.accent.b, 0.15)
                : Qt.rgba(255, 255, 255, 0.04)

            Text {
                anchors.centerIn: parent
                text: contextOption.icon
                font.family: contextOption.theme ? contextOption.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: contextOption.checked ? contextOption.accent : contextOption.subText
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: contextOption.title
                font.family: contextOption.theme ? contextOption.theme.fontMain : "Inter"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: contextOption.mainText
            }

            Text {
                Layout.fillWidth: true
                text: contextOption.detail
                elide: Text.ElideRight
                font.family: contextOption.theme ? contextOption.theme.fontMain : "Inter"
                font.pixelSize: 10
                color: contextOption.subText
            }
        }

        Rectangle {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: 7
            color: contextOption.checked ? contextOption.accent : Qt.rgba(255, 255, 255, 0.045)
            border.width: contextOption.checked ? 0 : 1
            border.color: Qt.rgba(255, 255, 255, 0.11)

            Text {
                anchors.centerIn: parent
                visible: contextOption.checked
                text: "check"
                font.family: contextOption.theme ? contextOption.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 14
                color: contextOption.theme ? contextOption.theme.bgBase : "#101014"
            }
        }
    }

    MouseArea {
        id: optionMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: contextOption.toggled()
    }
}
