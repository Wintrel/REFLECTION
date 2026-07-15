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
                            implicitHeight: 56
                            radius: 8
                            color: Qt.rgba(255, 255, 255, 0.02)
                            border.width: 1
                            border.color: Qt.rgba(255, 255, 255, 0.04)

                            property bool justCopied: false

                            Timer {
                                id: copyTimer
                                interval: 2000
                                onTriggered: justCopied = false
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 16

                                Text {
                                    text: "key"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 20
                                    color: root.theme ? root.theme.accentPrimary : "#AAA"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: modelData.name
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: root.theme ? root.theme.textMain : "#FFF"
                                    }
                                    Text {
                                        text: modelData.type + (modelData.comment ? " • " + modelData.comment : "")
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: root.theme ? root.theme.textSub : "#888"
                                        elide: Text.ElideRight
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: justCopied ? 85 : 70
                                    Layout.preferredHeight: 32
                                    radius: 6
                                    color: justCopied ? "#00C851" : (maCopy.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.08))
                                    border.width: 1
                                    border.color: justCopied ? "#00C851" : (maCopy.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.04))
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: justCopied ? "Copied!" : "Copy"
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: justCopied || maCopy.containsMouse ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                                    }

                                    MouseArea {
                                        id: maCopy
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            AccountService.copyToClipboard(modelData.content);
                                            justCopied = true;
                                            copyTimer.restart();
                                        }
                                    }
                                }
                            }
                        }