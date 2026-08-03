import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

// 5. Storage Quota
            ColumnLayout {
    id: root
    property var theme

                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Home Storage Quota"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 128
                    radius: 10
                    color: Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.04)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 11
                                color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.13) : Qt.rgba(0.4, 0.4, 1, 0.13)
                                Text {
                                    anchors.centerIn: parent
                                    text: "storage"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 23
                                    color: root.theme ? root.theme.accentPrimary : "#AAA"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "Home Partition"
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                }
                                Text {
                                    text: AccountService.homeDir
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 10
                                    color: root.theme ? root.theme.textSub : "#888"
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                spacing: 2
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: AccountService.storageUsage.used + " / " + AccountService.storageUsage.size
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                }
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: AccountService.storageUsage.avail + " available"
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 10
                                    color: root.theme ? root.theme.textSub : "#888"
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Storage utilization"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 10
                                color: root.theme ? root.theme.textMuted : "#666"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: AccountService.storageUsage.percent + "% used"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: AccountService.storageUsage.percent > 85 ? "#ff6666" : (root.theme ? root.theme.textSub : "#888")
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 7
                            radius: 4
                            color: Qt.rgba(255, 255, 255, 0.08)

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
