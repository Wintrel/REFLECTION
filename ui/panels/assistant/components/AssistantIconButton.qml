import QtQuick
import QtQuick.Controls

Rectangle {
    id: iconButton

    property var theme: null
    property string icon: ""
    property string toolTip: ""
    property bool highlighted: false

    signal clicked()

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color cardColor: theme ? theme.surfaceCard : "#111115"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"

    implicitWidth: 42
    implicitHeight: 42
    radius: 13
    color: highlighted
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.16)
        : (iconMouse.containsMouse ? cardColor : "transparent")
    border.width: highlighted ? 1 : 0
    border.color: highlighted
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.30)
        : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: iconButton.icon
        font.family: iconButton.theme ? iconButton.theme.fontIcon : "Material Symbols Rounded"
        font.pixelSize: 20
        color: iconButton.highlighted ? iconButton.accent : iconButton.subText
    }

    MouseArea {
        id: iconMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: iconButton.clicked()
    }

    ToolTip.visible: iconButton.toolTip !== "" && iconMouse.containsMouse
    ToolTip.text: iconButton.toolTip
    ToolTip.delay: 450
}
