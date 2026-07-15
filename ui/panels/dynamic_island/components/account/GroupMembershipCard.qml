import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

// 6. Group Membership
            ColumnLayout {
    id: root
    property var theme
    property var commonGroups: [
        { name: "wheel", label: "Administrators", desc: "Allows administrative actions via sudo/pkexec", icon: "security" },
        { name: "docker", label: "Docker Engine", desc: "Allows container management without sudo", icon: "layers" },
        { name: "video", label: "Video Hardware", desc: "GPU, webcam, and direct framebuffer access", icon: "videocam" },
        { name: "audio", label: "Audio Hardware", desc: "Direct access to sound card and MIDI hardware", icon: "volume_up" },
        { name: "input", label: "Input Devices", desc: "Access raw mouse, keyboard, and controller devices", icon: "keyboard" },
        { name: "i2c", label: "System Sensors", desc: "Hardware monitor sensors and backlight control", icon: "thermostat" },
        { name: "storage", label: "Device Storage", desc: "Direct mounting of external drives/filesystems", icon: "usb" }
    ]

                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "System Group Memberships"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "Manage access to hardware, containers, and administration. Group changes require authentication and system relog to apply."
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
                        model: root.commonGroups
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 64
                            radius: 8
                            color: isMember ? Qt.rgba(255, 255, 255, 0.04) : (maGroupCard.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : Qt.rgba(255, 255, 255, 0.015))
                            border.width: 1
                            border.color: isMember ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maGroupCard.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04))
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            scale: maGroupCard.containsMouse ? 1.01 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            readonly property string gName: modelData.name
                            readonly property bool isMember: AccountService.userGroupsList.indexOf(gName) !== -1

                            MouseArea {
                                id: maGroupCard
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    AccountService.toggleGroupMembership(gName, !isMember);
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 16

                                Text {
                                    text: modelData.icon
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 22
                                    color: isMember ? (root.theme ? root.theme.accentPrimary : "#AAA") : (root.theme ? root.theme.textSub : "#888")
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: modelData.label + " (" + gName + ")"
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: root.theme ? root.theme.textMain : "#FFF"
                                    }
                                    Text {
                                        text: modelData.desc
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: root.theme ? root.theme.textSub : "#888"
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: isMember ? "check_circle" : "add_circle_outline"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 20
                                    color: isMember ? "#4ADE80" : (root.theme ? root.theme.textSub : "#888")
                                }
                            }
                        }
                    }
                }
            }
