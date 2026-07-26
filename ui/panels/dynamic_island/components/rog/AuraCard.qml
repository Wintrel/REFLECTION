import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 12

    Text {
        text: "Configure keyboard backlight and animation effects."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }

    // ── Brightness Card ──────────────────────────────────────────────────────
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: brightnessRow.implicitHeight + 28
        radius: 12
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.05)

        RowLayout {
            id: brightnessRow
            anchors {
                fill: parent
                leftMargin: 16
                rightMargin: 16
                topMargin: 14
                bottomMargin: 14
            }
            spacing: 14

            Text {
                text: "keyboard"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 22
                color: brightnessSlider.pressed
                    ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                    : (root.theme ? root.theme.textSub : "#888")
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Brightness"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    value: 0.5 // Placeholder

                    background: Rectangle {
                        x: parent.leftPadding
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: parent.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: Qt.rgba(255, 255, 255, 0.1)

                        Rectangle {
                            width: parent.parent.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: brightnessSlider.pressed
                                ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                                : Qt.rgba(255, 255, 255, 0.4)
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    handle: Rectangle {
                        x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        implicitWidth: 14
                        implicitHeight: 14
                        radius: 7
                        color: brightnessSlider.pressed
                            ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                            : "#FFF"
                        border.width: 2
                        border.color: Qt.rgba(0, 0, 0, 0.3)
                        Behavior on color { ColorAnimation { duration: 200 } }

                        scale: brightnessSlider.pressed ? 1.2 : (brightnessSlider.hovered ? 1.1 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    }
                }
            }

            Text {
                text: Math.round(brightnessSlider.value * 100) + "%"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 12
                color: root.theme ? root.theme.textSub : "#888"
                Layout.preferredWidth: 32
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    // ── Effects Card ─────────────────────────────────────────────────────────
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: effectsRow.implicitHeight + 24
        radius: 12
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.05)

        RowLayout {
            id: effectsRow
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 8

            Repeater {
                model: [
                    { name: "Static",  icon: "horizontal_rule" },
                    { name: "Breathe", icon: "air"             },
                    { name: "Rainbow", icon: "palette"         },
                    { name: "Strobe",  icon: "flare"           }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 10

                    property bool isCurrent: index === 0 // Placeholder

                    color: isCurrent
                        ? Qt.rgba(
                            root.theme ? root.theme.accentPrimary.r : 1,
                            root.theme ? root.theme.accentPrimary.g : 0.7,
                            root.theme ? root.theme.accentPrimary.b : 0,
                            0.15)
                        : (maEffect.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")

                    border.width: 1
                    border.color: isCurrent
                        ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                        : (maEffect.containsMouse ? Qt.rgba(255, 255, 255, 0.12) : Qt.rgba(255, 255, 255, 0.06))

                    Behavior on color       { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    scale: maEffect.containsMouse ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.icon
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: isCurrent
                                ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                                : (root.theme ? root.theme.textMain : "#FFF")
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            font.weight: isCurrent ? Font.DemiBold : Font.Normal
                            color: isCurrent
                                ? (root.theme ? root.theme.accentPrimary : "#FFC66D")
                                : (root.theme ? root.theme.textMain : "#FFF")
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        id: maEffect
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {}
                    }
                }
            }
        }
    }
}
