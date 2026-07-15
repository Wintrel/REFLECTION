import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

// 2. Display Name
            ColumnLayout {
    id: root
    property var theme

                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Display Name"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 6
                        color: nameInput.activeFocus ? Qt.rgba(0, 0, 0, 0.4) : Qt.rgba(0, 0, 0, 0.25)
                        border.width: 1
                        border.color: nameInput.activeFocus ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maNameInput.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.06))
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        TextInput {
                            id: nameInput
                            anchors.fill: parent
                            anchors.margins: 12
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.theme ? root.theme.textMain : "#FFF"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            text: AccountService.realName
                        }

                        MouseArea {
                            id: maNameInput
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: nameInput.forceActiveFocus()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 40
                        radius: 6
                        color: maName.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.08)
                        border.width: 1
                        border.color: maName.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.04)
                        opacity: nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0 ? 1.0 : 0.5
                        scale: maName.containsMouse && nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0 ? 1.03 : 1.0
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Apply"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: maName.containsMouse && nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0 ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                        }

                        MouseArea {
                            id: maName
                            anchors.fill: parent
                            enabled: nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0
                            hoverEnabled: enabled
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                AccountService.setRealName(nameInput.text);
                            }
                        }
                    }
                }
            }
