import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

// 8. Active Login Sessions..
            ColumnLayout {
    id: root
    property var theme

                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Active Login Sessions"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "Current logged-in system sessions. You can terminate remote or background console sessions directly."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: AccountService.activeSessions
                        delegate: Rectangle {
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

                                // Current badge
                                Rectangle {
                                    visible: isCurrentSession
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    Layout.rightMargin: 16
                                    height: 26
                                    implicitWidth: 80
                                    radius: 13
                                    color: Qt.rgba(255, 255, 255, 0.03)
                                    border.width: 1
                                    border.color: Qt.rgba(255, 255, 255, 0.08)
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        
                                        Rectangle {
                                            width: 6; height: 6; radius: 3
                                            color: "#4ADE80"
                                            // simple dot, no dropshadow to keep it lightweight, or basic glowing color
                                        }
                                        
                                        Text {
                                            text: "Current"
                                            font.family: "Inter"
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold
                                            color: "#E0E0E0"
                                        }
                                    }
                                }

                                // Terminate Button
                                Rectangle {
                                    visible: !isCurrentSession
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    Layout.rightMargin: 16
                                    height: 32
                                    implicitWidth: maTerm.containsMouse ? 105 : 32
                                    radius: 16
                                    color: maTerm.containsMouse ? "#ef4444" : Qt.rgba(255, 255, 255, 0.03)
                                    border.width: 1
                                    border.color: maTerm.containsMouse ? "#ef4444" : Qt.rgba(255, 255, 255, 0.08)
                                    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on border.color { ColorAnimation { duration: 200 } }
                                    clip: true

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        
                                        Text {
                                            text: "close"
                                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                            font.pixelSize: 18
                                            color: maTerm.containsMouse ? "#FFFFFF" : "#ef4444"
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                        }
                                        
                                        Text {
                                            visible: maTerm.containsMouse
                                            text: "Terminate"
                                            font.family: "Inter"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: "#FFFFFF"
                                        }
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
            }
