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
                    implicitHeight: 80
                    radius: 8
                    color: Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.04)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: "storage"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 28
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Home Partition (" + AccountService.homeDir + ")"
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: AccountService.storageUsage.used + " / " + AccountService.storageUsage.size + " (" + AccountService.storageUsage.percent + "% used)"
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    color: root.theme ? root.theme.textSub : "#888"
                                }
                            }

                            // Progress Bar Track
                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: Qt.rgba(255, 255, 255, 0.08)

                                // Progress Fill
                                Rectangle {
                                    width: parent.width * (AccountService.storageUsage.percent / 100.0)
                                    height: parent.height
                                    radius: parent.radius
                                    color: {
                                        var pct = AccountService.storageUsage.percent;
                                        if (pct > 85) return "#ff4444";
                                        if (pct > 65) return "#ffbb33";
                                        return root.theme ? root.theme.accentPrimary : "#C0C0D0";
                                    }
                                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }
                    }
                }