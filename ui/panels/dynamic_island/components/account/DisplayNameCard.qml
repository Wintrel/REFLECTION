import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

Rectangle {
    id: root
    property var theme

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