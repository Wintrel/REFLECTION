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
                            implicitHeight: 64
                            radius: 8
                            color: isCurrentSession ? Qt.rgba(255, 255, 255, 0.04) : (maSessionCard.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : Qt.rgba(255, 255, 255, 0.015))
                            border.width: 1
                            border.color: isCurrentSession ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maSessionCard.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04))
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            readonly property string sId: modelData.id
                            readonly property string sType: modelData.type
                            readonly property string sTty: modelData.tty
                            readonly property string sDesktop: modelData.desktop
                            readonly property bool isCurrentSession: Quickshell.env("XDG_SESSION_ID") === sId

                            MouseArea {
                                id: maSessionCard
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: isCurrentSession ? Qt.ArrowCursor : Qt.PointingHandCursor
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 16

                                Text {
                                    text: sType === "wayland" || sType === "x11" ? "desktop_windows" : "terminal"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 22
                                    color: isCurrentSession ? (root.theme ? root.theme.accentPrimary : "#AAA") : (root.theme ? root.theme.textSub : "#888")
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: {
                                            var desc = "";
                                            if (sDesktop) desc += sDesktop + " (";
                                            desc += sType.charAt(0).toUpperCase() + sType.slice(1);
                                            if (sDesktop) desc += ")";
                                            if (sTty) desc += " on " + sTty;
                                            return desc;
                                        }
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: root.theme ? root.theme.textMain : "#FFF"
                                    }
                                    Text {
                                        text: "Active for " + modelData.duration + (modelData.service ? " • via " + modelData.service : "")
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: root.theme ? root.theme.textSub : "#888"
                                        elide: Text.ElideRight
                                    }
                                }

                                // Status Badge / Terminate Button
                                Item {
                                    Layout.preferredWidth: badgeContainer.implicitWidth
                                    Layout.preferredHeight: 32

                                    RowLayout {
                                        id: badgeContainer
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8

                                        // Current badge
                                        Rectangle {
                                            visible: isCurrentSession
                                            height: 24
                                            width: 75
                                            radius: 12
                                            color: Qt.rgba(74, 222, 128, 0.15)
                                            border.width: 1
                                            border.color: "#4ADE80"
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Current"
                                                font.family: "Inter"
                                                font.pixelSize: 11
                                                font.weight: Font.Bold
                                                color: "#4ADE80"
                                            }
                                        }

                                        // Terminate Button
                                        Rectangle {
                                            visible: !isCurrentSession
                                            height: 32
                                            width: 85
                                            radius: 6
                                            color: maTerm.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.1)
                                            border.width: 1
                                            border.color: maTerm.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.2)
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                            Behavior on border.color { ColorAnimation { duration: 150 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Terminate"
                                                font.family: "Inter"
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: maTerm.containsMouse ? "#FFF" : "#ff4444"
                                            }

                                            MouseArea {
                                                id: maTerm
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    AccountService.terminateSession(sId);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }