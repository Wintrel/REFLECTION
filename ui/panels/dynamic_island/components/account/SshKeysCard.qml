import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

// 7. SSH Public Keys
            ColumnLayout {
    id: root
    property var theme

                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "SSH Public Keys"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "Public keys in ~/.ssh directory. Copy them to add to your remote profiles (e.g., GitHub, GitLab)."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: AccountService.sshKeys.length > 0

                    Repeater {
                        model: AccountService.sshKeys
                        delegate: Rectangle {
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
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    Layout.rightMargin: 16
                                    Layout.preferredWidth: justCopied ? 85 : 36
                                    Layout.preferredHeight: 32
                                    radius: 16
                                    color: justCopied ? Qt.rgba(74, 222, 128, 0.15) : (maCopy.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(255, 255, 255, 0.03))
                                    border.width: 1
                                    border.color: justCopied ? "#4ADE80" : (maCopy.containsMouse ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(255, 255, 255, 0.08))
                                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on border.color { ColorAnimation { duration: 200 } }
                                    clip: true

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text {
                                            visible: !justCopied
                                            text: "content_copy"
                                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                            font.pixelSize: 16
                                            color: maCopy.containsMouse ? "#FFFFFF" : "#AAAAAA"
                                        }
                                        Text {
                                            visible: justCopied
                                            text: "Copied!"
                                            font.family: "Inter"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: "#4ADE80"
                                        }
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
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 8
                    color: Qt.rgba(255, 255, 255, 0.015)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.04)
                    visible: AccountService.sshKeys.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: "No SSH public keys (*.pub) found in ~/.ssh/"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                }
            }
