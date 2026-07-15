import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

// 3. Password
            ColumnLayout {
    id: root
    property var theme
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

                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Password"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "You will be prompted to authenticate with your old password."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
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

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 40
                        radius: 6
                        color: maPass.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.1)
                        border.width: 1
                        border.color: maPass.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.2)
                        opacity: passInput.text.length > 0 ? 1.0 : 0.5
                        scale: maPass.containsMouse && passInput.text.length > 0 ? 1.03 : 1.0
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Change"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: maPass.containsMouse && passInput.text.length > 0 ? "#FFF" : "#ff4444"
                        }

                        MouseArea {
                            id: maPass
                            anchors.fill: parent
                            hoverEnabled: passInput.text.length > 0
                            cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (passInput.text.length > 0) {
                                    AccountService.setPassword(passInput.text);
                                    passInput.text = ""; // clear after submitting
                                }
                            }
                        }
                    }
                }

                // Password strength bar indicators
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: passInput.text.length > 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Repeater {
                            model: 5
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                radius: 2
                                color: {
                                    if (index < root.passStrength) {
                                        if (root.passStrength <= 2) return "#ff4444"; // Weak - Red
                                        if (root.passStrength <= 4) return "#ffbb33"; // Medium - Orange
                                        return "#00C851"; // Strong - Green
                                    } else {
                                        return Qt.rgba(255, 255, 255, 0.1);
                                    }
                                }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    Text {
                        text: {
                            if (root.passStrength === 0) return "";
                            if (root.passStrength <= 2) return "Weak password";
                            if (root.passStrength <= 4) return "Moderate password";
                            return "Strong password";
                        }
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: {
                            if (root.passStrength <= 2) return "#ff4444";
                            if (root.passStrength <= 4) return "#ffbb33";
                            return "#00C851";
                        }
                    }
                }
            }
