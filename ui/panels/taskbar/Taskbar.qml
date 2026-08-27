import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

import "../../../core" as Core
import "../../../core/state" as State
import "../../../core/services/system"
import "../../../core/monitors"
import "components"
import "../../components" as Components
import "../control_center" as CC

// Scope container — Variants manages the PanelWindow lifecycle on monitor changes.
Scope {
    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            id: taskbarWindow

            required property var modelData
            screen: modelData
            visible: ShellService.taskbarEnabled

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors {
                bottom: true
                left: true
                right: true
            }

            // Make sure the window acts as an overlay and doesn't take up literal screen space
            exclusiveZone: 0
            color: "transparent"

            // Height needs to fit the visible taskbar plus the 600px Start Menu
            implicitHeight: 800

            mask: Region {
                Region {
                    item: clickawayMask
                }
                Region {
                    item: edgeTrigger
                }
                Region {
                    item: taskbarWrapper
                }
                Region {
                    item: ccContainer
                }
            }

            property var theme: Core.Theme { id: theme }
            
            // Dedicated bottom edge trigger strip for 100% reliable auto-hide reveal
            Item {
                id: edgeTrigger
                width: parent.width
                height: 6
                anchors.bottom: parent.bottom
                HoverHandler { id: edgeHover }
            }

            // Clickaway handler for closing Control Center
            Item {
                id: clickawayMask
                width: parent.width
                height: State.GlobalStates.controlCenterOpen ? parent.height : 0
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        State.GlobalStates.controlCenterOpen = false;
                    }
                }
            }

            Item {
                id: taskbarWrapper
                width: taskbarContainer.width + (theme.floatingTaskbar ? 0 : (2 * theme.taskbarRadius))
                height: theme.floatingTaskbar ? (theme.taskbarHeight + theme.taskbarBottomMargin) : (taskbarContainer.height - theme.taskbarRadius)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                readonly property bool rawHovered: taskbarHover.hovered || edgeHover.hovered
                property bool isRevealed: false

                onRawHoveredChanged: {
                    if (rawHovered) {
                        hideDebounceTimer.stop();
                        isRevealed = true;
                    } else {
                        hideDebounceTimer.restart();
                    }
                }

                Timer {
                    id: hideDebounceTimer
                    interval: 350
                    repeat: false
                    onTriggered: {
                        if (!taskbarWrapper.rawHovered && !State.GlobalStates.controlCenterOpen) {
                            taskbarWrapper.isRevealed = false;
                        }
                    }
                }

                property bool isHidden: {
                    if (State.GlobalStates.anyAmbientActive)
                        return true;
                    if (ShellService.taskbarVisibilityMode === 1)
                        return false;
                    if (ShellService.taskbarVisibilityMode === 2)
                        return !isRevealed && !State.GlobalStates.controlCenterOpen;
                    return !HyprlandService.isWorkspaceEmpty && !isRevealed && !State.GlobalStates.controlCenterOpen;
                }

                anchors.bottomMargin: isHidden ? -(height + 20) : 0
                Behavior on anchors.bottomMargin { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }

                HoverHandler { id: taskbarHover }

                    Rectangle {
                        id: taskbarContainer

                        width: taskbarWindow.width * theme.taskbarWidthPercent
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

                        height: theme.floatingTaskbar ? theme.taskbarHeight : (theme.taskbarHeight + theme.taskbarRadius)
                        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: theme.floatingTaskbar ? theme.taskbarBottomMargin : -theme.taskbarRadius
                        Behavior on anchors.bottomMargin { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

                        radius: theme.taskbarRadius
                        Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                        color: theme.bgBezel

                        // Inner inset area
                        Rectangle {
                            anchors.fill: parent
                            anchors.leftMargin: theme.taskbarBorderWidth
                            anchors.rightMargin: theme.taskbarBorderWidth
                            anchors.topMargin: theme.taskbarBorderWidth
                            anchors.bottomMargin: theme.floatingTaskbar ? theme.taskbarBorderWidth : (theme.taskbarRadius + theme.taskbarBorderWidth)

                            radius: Math.max(0, parent.radius - theme.taskbarBorderWidth)
                            Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                            color: theme.bgInner
                            clip: true
                            
                            Components.Starfield {
                                anchors.fill: parent
                                anchors.margins: -10
                                starColor: theme.textMain
                                opacity: 0.5
                            }
                        }
                        
                        // Patch to square off the top-right corner when Control Center is fused in docked mode
                        Item {
                            width: theme.taskbarRadius
                            height: theme.taskbarRadius
                            anchors.top: parent.top
                            anchors.right: parent.right
                            visible: !theme.floatingTaskbar
                            
                            opacity: State.GlobalStates.controlCenterOpen ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 500 } }
                            
                            // Outer Bezel
                            Rectangle {
                                anchors.fill: parent
                                color: theme.bgBezel
                            }
                            
                            // Inner Fill
                            Rectangle {
                                anchors.fill: parent
                                anchors.topMargin: theme.taskbarBorderWidth
                                anchors.rightMargin: theme.taskbarBorderWidth
                                color: theme.bgInner
                            }
                        }

                        // Layout
                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            anchors.bottomMargin: theme.floatingTaskbar ? 0 : theme.taskbarRadius // Push bottom up so vertical center is correct

                            // Left: Workspaces
                            WorkspaceDots {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                theme: taskbarWindow.theme
                            }

                            // Center: Apps
                            AppNav {
                                anchors.centerIn: parent
                                theme: taskbarWindow.theme
                            }

                            // Right: System Tray (Clock, Battery, etc)
                            SystemTray {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                theme: taskbarWindow.theme
                            }
                        }
                    }

                    TaskbarFillets {
                        visible: !theme.floatingTaskbar
                        taskbarShape: taskbarContainer
                        radiusTaskbar: theme.taskbarRadius
                        bgBezel: theme.bgBezel
                    }

                    // The Fused Control Center
                    Item {
                        id: ccContainer
                        z: -1
                        width: 380
                        height: ccUI.implicitHeight
                        Behavior on height { NumberAnimation { duration: 500; easing.type: Easing.OutExpo } }
                        
                        // --- HORIZONTAL PLACEMENT ---
                        anchors.right: taskbarContainer.right
                        
                        // --- VERTICAL PLACEMENT ---
                        anchors.bottom: taskbarContainer.top
                        anchors.bottomMargin: theme.floatingTaskbar ? 10 : 0
                        Behavior on anchors.bottomMargin { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                        
                        // Set to 0 so it sits perfectly behind the flat top edge of the taskbar
                        property bool isOpen: State.GlobalStates.controlCenterOpen
                        
                        transform: Translate {
                            y: ccContainer.isOpen ? 0 : ccContainer.height + taskbarContainer.height
                            Behavior on y { NumberAnimation { duration: 700; easing.type: Easing.OutExpo } }
                        }
                        
                        CC.ControlCenterUI {
                            id: ccUI
                            anchors.fill: parent
                            theme: taskbarWindow.theme
                            isOpen: ccContainer.isOpen
                        }
                        
                        // --- THE LEFT SWOOP (FILLET) ---
                        Item {
                            width: theme.taskbarRadius
                            height: theme.taskbarRadius
                            anchors.bottom: parent.bottom
                            anchors.right: parent.left
                            visible: !theme.floatingTaskbar
                            clip: true
                            
                            Rectangle {
                                width: 4 * theme.taskbarRadius
                                height: 4 * theme.taskbarRadius
                                radius: 2 * theme.taskbarRadius
                                color: "transparent"
                                border.color: theme.bgBezel
                                border.width: theme.taskbarRadius
                                x: -2 * theme.taskbarRadius
                                y: -2 * theme.taskbarRadius 
                            }
                        }
                    }
                }
            }
        }
    }
