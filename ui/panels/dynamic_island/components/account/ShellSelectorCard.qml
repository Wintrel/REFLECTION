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

                            width: 140
                            height: 48
                            radius: 8
                            color: isCurrent ? Qt.rgba(255, 255, 255, 0.08) : (maShell.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02))
                            border.width: 1
                            border.color: isCurrent ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maShell.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(255, 255, 255, 0.04))
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            scale: maShell.containsMouse ? 1.03 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            readonly property string shellPath: modelData
                            readonly property bool isCurrent: {
                                var p1 = shellPath.split("/").pop();
                                var p2 = AccountService.loginShell.split("/").pop();
                                return p1 === p2;
                            }

                            MouseArea {
                                id: maShell
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    AccountService.setShell(shellPath);
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: isCurrent ? "radio_button_checked" : "radio_button_unchecked"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 16
                                    color: isCurrent ? (root.theme ? root.theme.accentPrimary : "#AAA") : (root.theme ? root.theme.textSub : "#888")
                                }

                                Text {
                                    text: {
                                        var p = shellPath.split("/");
                                        return p[p.length - 1];
                                    }
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    font.weight: isCurrent ? Font.Medium : Font.Normal
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }