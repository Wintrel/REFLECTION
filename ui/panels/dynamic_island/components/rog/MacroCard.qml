import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../../../core/services/system"

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 12

    // Which slot is currently being edited (-1 = none)
    property int editingSlot: -1

    // Icon for a given macro label
    function iconForLabel(label) {
        var icons = {
            "Unmapped": "keyboard",
            "Volume Down": "volume_down",
            "Volume Up": "volume_up",
            "Mute Audio": "volume_off",
            "Mute Microphone": "mic_off",
            "Play / Pause": "play_arrow",
            "Next Track": "skip_next",
            "Previous Track": "skip_previous",
            "Screenshot Region": "screenshot_region",
            "Screenshot Full": "screenshot_monitor",
            "Toggle DND": "do_not_disturb_on",
            "Immersive Settings": "settings"
        };
        return icons[label] || "keyboard";
    }

    Text {
        text: "Configure the macro keys on your laptop."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#888"
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: macroCol.implicitHeight + 16
        radius: 12
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.05)

        ColumnLayout {
            id: macroCol
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater {
                model: RogService.macros

                delegate: ColumnLayout {
                    id: macroDelegate
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 0

                    // ── Macro row ──────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: 8

                        property bool isEditing: root.editingSlot === macroDelegate.index

                        color: isEditing
                            ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.08)
                                          : Qt.rgba(0.4, 0.4, 1, 0.08))
                            : (rowMa.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : "transparent")
                        border.width: 1
                        border.color: isEditing && root.theme
                            ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.25)
                            : (rowMa.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent")

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 16

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 8
                                color: Qt.rgba(255, 255, 255, 0.05)

                                Text {
                                    anchors.centerIn: parent
                                    text: root.iconForLabel(macroDelegate.modelData.label)
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 18
                                    color: macroDelegate.modelData.presetIndex > 0 && root.theme
                                        ? root.theme.accentPrimary
                                        : (root.theme ? root.theme.textMain : "#FFF")
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: RogService.macroNames[macroDelegate.index]
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                }

                                Text {
                                    text: macroDelegate.modelData.label
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 11
                                    color: macroDelegate.modelData.presetIndex > 0
                                        ? (root.theme ? root.theme.textSub : "#888")
                                        : (root.theme ? root.theme.textMuted || root.theme.textSub : "#555")
                                }
                            }

                            Text {
                                text: parent.parent.isEditing ? "expand_less" : "chevron_right"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 18
                                color: root.theme ? root.theme.textSub : "#888"
                            }
                        }

                        MouseArea {
                            id: rowMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.editingSlot = root.editingSlot === macroDelegate.index ? -1 : macroDelegate.index;
                            }
                        }
                    }

                    // ── Preset picker (expanded) ──────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        visible: root.editingSlot === macroDelegate.index
                        implicitHeight: visible ? presetGrid.implicitHeight + 16 : 0
                        radius: 8
                        color: Qt.rgba(255, 255, 255, 0.015)
                        clip: true

                        Behavior on implicitHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                        opacity: visible ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        GridLayout {
                            id: presetGrid
                            anchors.fill: parent
                            anchors.margins: 8
                            columns: width >= 400 ? 3 : 2
                            columnSpacing: 6
                            rowSpacing: 6

                            Repeater {
                                model: RogService.macroPresets

                                delegate: Rectangle {
                                    required property int index
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38
                                    radius: 8

                                    property bool isSelected: macroDelegate.modelData.presetIndex === index

                                    color: isSelected
                                        ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.15)
                                                      : Qt.rgba(0.4, 0.4, 1, 0.15))
                                        : (presetMa.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(255, 255, 255, 0.02))
                                    border.width: 1
                                    border.color: isSelected
                                        ? (root.theme ? root.theme.accentPrimary : "#7777DD")
                                        : (presetMa.containsMouse ? Qt.rgba(255, 255, 255, 0.10) : Qt.rgba(255, 255, 255, 0.04))

                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Behavior on border.color { ColorAnimation { duration: 120 } }

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Text {
                                            text: root.iconForLabel(modelData.label)
                                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                            font.pixelSize: 14
                                            color: isSelected && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#888")
                                        }
                                        Text {
                                            text: modelData.label
                                            font.family: root.theme ? root.theme.fontMain : "Inter"
                                            font.pixelSize: 10
                                            font.weight: isSelected ? Font.DemiBold : Font.Normal
                                            color: isSelected && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textMain : "#FFF")
                                        }
                                    }

                                    MouseArea {
                                        id: presetMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            RogService.setMacro(macroDelegate.index, index);
                                            root.editingSlot = -1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
