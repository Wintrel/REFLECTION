import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../../core" as Core
import "../../../core/monitors"
import "../../../core/state" as State
import "../../../core/services/system"
import "../../components" as Components

Scope {
    id: ciderStudioScope

    IpcHandler {
        target: "ciderStudio"

        function open() {
            State.GlobalStates.openCiderStudioWorkspace();
        }

        function close() {
            State.GlobalStates.closeCiderStudioWorkspace();
        }

        function toggle() {
            State.GlobalStates.toggleCiderStudioWorkspace();
        }
    }

    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            id: ciderStudioWindow

            required property var modelData
            screen: modelData

            Core.Theme { id: theme }

            property bool wantsVisible: State.GlobalStates.ciderStudioWorkspaceOpen
            visible: wantsVisible || closeTimer.running
            color: "transparent"

            WlrLayershell.namespace: "quickshell:ciderStudio"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: wantsVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0

            Timer {
                id: closeTimer
                interval: 260
            }

            onWantsVisibleChanged: {
                if (wantsVisible)
                    closeTimer.stop();
                else
                    closeTimer.restart();
            }

            Shortcut {
                sequence: "Escape"
                context: Qt.WindowShortcut
                enabled: ciderStudioWindow.wantsVisible
                onActivated: State.GlobalStates.closeCiderStudioWorkspace()
            }

            Rectangle {
                anchors.fill: parent
                color: theme ? theme.bgBase : "#09090d"
                opacity: ciderStudioWindow.wantsVisible ? 0.97 : 0
                Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.InOutQuad } }

                Image {
                    anchors.fill: parent
                    source: WallpaperService.currentWallpaper
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    opacity: 0.035
                }

                Components.Starfield {
                    anchors.fill: parent
                    starCount: 70
                    starColor: theme ? theme.textMain : "#ffffff"
                    opacity: 0.18
                }

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0
                            color: theme ? Qt.rgba(theme.accentMusic.r, theme.accentMusic.g, theme.accentMusic.b, 0.035) : "transparent"
                        }
                        GradientStop { position: 0.42; color: "transparent" }
                        GradientStop {
                            position: 1
                            color: theme ? Qt.rgba(theme.accentSecondary.r, theme.accentSecondary.g, theme.accentSecondary.b, 0.025) : "transparent"
                        }
                    }
                }
            }

            Item {
                id: contentRoot
                anchors.fill: parent
                opacity: ciderStudioWindow.wantsVisible ? 1 : 0
                scale: ciderStudioWindow.wantsVisible ? 1 : 0.985
                transform: Translate {
                    y: ciderStudioWindow.wantsVisible ? 0 : 16
                    Behavior on y { NumberAnimation { duration: 360; easing.type: Easing.OutExpo } }
                }
                Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutQuad } }
                Behavior on scale { NumberAnimation { duration: 360; easing.type: Easing.OutExpo } }

                Item {
                    id: topLane
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 12
                            color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.15) : Qt.rgba(0.5, 0.5, 1, 0.15)
                            border.width: 1
                            border.color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.25) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "music_note"
                                font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 20
                                color: theme ? theme.accentPrimary : "#8c8cff"
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: "REFLECTION"
                                font.family: theme ? theme.fontMain : "Inter"
                                font.pixelSize: 9
                                font.letterSpacing: 1.5
                                font.weight: Font.Bold
                                color: theme ? theme.accentPrimary : "#8c8cff"
                            }

                            Text {
                                text: "Cider Studio"
                                font.family: theme ? theme.fontMain : "Inter"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: theme ? theme.textMain : "#ffffff"
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        width: 92
                        height: 38
                        radius: 12
                        color: closeMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.075) : Qt.rgba(255, 255, 255, 0.035)
                        border.width: 1
                        border.color: Qt.rgba(255, 255, 255, 0.06)

                        Row {
                            anchors.centerIn: parent
                            spacing: 7
    
                            Text {
                                text: "close"
                                font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 17
                                color: theme ? theme.textSub : "#aaaaaa"
                            }

                            Text {
                                text: "Close"
                                font.family: theme ? theme.fontMain : "Inter"
                                font.pixelSize: 11
                                color: theme ? theme.textSub : "#aaaaaa"
                            }
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: State.GlobalStates.closeCiderStudioWorkspace()
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: Qt.rgba(255, 255, 255, 0.055)
                    }
                }

                CiderStudioWorkspace {
                    anchors.top: topLane.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    // Use the entire immersive canvas.
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.topMargin: 24
                    anchors.bottomMargin: 28
                    theme: theme
                }
            }
        }
    }
}
