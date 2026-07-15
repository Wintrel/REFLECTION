import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

Rectangle {
    property int passStrength: {
        var pass = passInput.text;
        if (pass.length === 0) return 0;
        var score = 0;
        if (pass.length >= 8) score += 1;
        if (/[A-Z]/.test(pass)) score += 1;
        if (/[a-z]/.test(pass)) score += 1;
        if (/[0-9]/.test(pass)) score += 1;
        if (/[^A-Za-z0-9]/.test(pass)) score += 1;
        return score; // 0 to 5
    }

    id: root
    property var theme

                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 6
                        color: passInput.activeFocus ? Qt.rgba(0, 0, 0, 0.4) : Qt.rgba(0, 0, 0, 0.25)
                        border.width: 1
                        border.color: passInput.activeFocus ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maPassInput.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.06))
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        TextInput {
                            id: passInput
                            anchors.left: parent.left
                            anchors.right: eyeButton.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 12
                            anchors.rightMargin: 4
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.theme ? root.theme.textMain : "#FFF"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                        }

                        MouseArea {
                            id: maPassInput
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: passInput.forceActiveFocus()
                        }

                        Text {
                            id: eyeButton
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: passInput.echoMode === TextInput.Password ? "visibility" : "visibility_off"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: maEye.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#888")
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: maEye
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    passInput.echoMode = (passInput.echoMode === TextInput.Password) ? TextInput.Normal : TextInput.Password;
                                }
                            }
                        }
                    }