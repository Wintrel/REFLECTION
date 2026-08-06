import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../control_center/components" as CC
import "../../../../../core/services/system"

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

    // ── Brightness ────────────────────────────────────────────────────────
    Text {
        text: "Brightness  ·  " + RogService.ledLevelNames[RogService.ledBrightness]
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textMain : "#FFF"
    }

    CC.ThickSlider {
        id: brightnessSlider
        Layout.fillWidth: true
        theme: root.theme
        icon: "keyboard"
        value: RogService.ledBrightness * 33.33
        valueText: RogService.ledLevelNames[RogService.ledBrightness]
        onValueChangedByUser: newValue => {
            // Map 0-100 slider range to 0-3 LED levels
            var level = Math.round(newValue / 33.33);
            RogService.setLedBrightness(level);
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

                    property bool isCurrent: index === RogService.auraEffect

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
                        onClicked: RogService.setAuraEffect(index)
                    }
                }
            }
        }
    }
}
