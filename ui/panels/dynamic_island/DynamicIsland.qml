import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../core" as Core
import "../../../core/monitors"
import "../../../core/state" as State

// Scope container — Variants manages the PanelWindow lifecycle on monitor changes.
// When the anchor screen disappears (unplug), the PanelWindow is destroyed.
// When a new anchor screen appears (replug/fallback), a fresh PanelWindow is created.
Scope {
    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            Core.Theme { id: theme }
            id: islandWindow

            required property var modelData
            screen: modelData

            WlrLayershell.keyboardFocus: {
                var exclusive = [State.IslandState.prompt, State.IslandState.reflectionGrid, State.IslandState.polkitAuth];
                var onDemand = [State.IslandState.settingsHub, State.IslandState.filePicker, State.IslandState.ciderExpanded, State.IslandState.clipboard, State.IslandState.expanded, State.IslandState.battery, State.IslandState.notificationHistory];
                
                if (exclusive.indexOf(widget.islandState) !== -1) return WlrKeyboardFocus.Exclusive;
                if (onDemand.indexOf(widget.islandState) !== -1) return WlrKeyboardFocus.OnDemand;
                return WlrKeyboardFocus.None;
            }
            

            
            // Render on top of fullscreen windows if enabled, otherwise use normal top layer
            WlrLayershell.layer: State.GlobalStates.islandInOverlay ? WlrLayer.Overlay : WlrLayer.Top
            
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            
            // Make sure the window acts as an overlay and doesn't take up literal screen space
            exclusiveZone: 0
            
            // Transparent background for the panel itself
            color: "transparent"
            
            Item {
                id: clickawayMask
                width: parent.width
                
                property bool isExpanded: widget.islandState === State.IslandState.ciderExpanded || 
                                          widget.islandState === State.IslandState.expanded ||
                                          widget.islandState === State.IslandState.battery ||
                                          widget.islandState === State.IslandState.settingsHub ||
                                          widget.islandState === State.IslandState.filePicker ||
                                          widget.islandState === State.IslandState.clipboard ||
                                          widget.islandState === State.IslandState.reflectionGrid ||
                                          widget.islandState === State.IslandState.notificationHistory

                height: isExpanded ? parent.height : 0
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (widget.islandState === State.IslandState.clipboard) {
                            State.GlobalStates.clipboardOpen = false;
                        } else if (widget.islandState === State.IslandState.filePicker) {
                            State.GlobalStates.closeFilePicker();
                        } else if (widget.islandState === State.IslandState.settingsHub) {
                            State.GlobalStates.settingsOpen = false;
                        } else if (widget.islandState === State.IslandState.reflectionGrid) {
                            State.ReflectionState.isOpen = false;
                        } else {
                            widget.islandState = State.IslandState.idle;
                        }
                    }
                }
            }
            
            // Mask the input/visual region exactly to the opaque pixels of the container
            // This perfectly prevents the window from blocking clicks on the desktop!
            mask: Region {
                Region {
                    item: clickawayMask
                }
                Region {
                    item: widget
                }
            }
            
            DynamicIslandWidget {
                id: widget
                anchors.horizontalCenter: parent.horizontalCenter
                
                anchors.top: parent.top
                anchors.topMargin: 0

                // Ambient hide: shimmer sweep → nod → slide away
                SequentialAnimation {
                    id: ambientHideAnim

                    // Phase 1: Electric blue shimmer sweeps across the island
                    ParallelAnimation {
                        NumberAnimation {
                            target: widget
                            property: "ambientShimmerPos"
                            from: -0.3
                            to: 1.3
                            duration: 600
                            easing.type: Easing.InOutSine
                        }
                        SequentialAnimation {
                            NumberAnimation { target: widget; property: "ambientShimmerOpacity"; to: 1; duration: 150 }
                            PauseAnimation { duration: 300 }
                            NumberAnimation { target: widget; property: "ambientShimmerOpacity"; to: 0; duration: 150 }
                        }
                    }

                    // Phase 2: Nod — brief dip down, a polite acknowledgment
                    NumberAnimation {
                        target: widget
                        property: "anchors.topMargin"
                        to: 3
                        duration: 150
                        easing.type: Easing.OutQuad
                    }

                    // Phase 3: Slide away behind the screen edge
                    NumberAnimation {
                        target: widget
                        property: "anchors.topMargin"
                        to: -widget.height - 20
                        duration: 500
                        easing.type: Easing.InOutCubic
                    }
                }

                // Ambient show: smooth slide back into view
                NumberAnimation {
                    id: ambientShowAnim
                    target: widget
                    property: "anchors.topMargin"
                    to: 0
                    duration: 700
                    easing.type: Easing.OutExpo
                }

                Connections {
                    target: State.GlobalStates
                    function onAnyAmbientActiveChanged() {
                        if (State.GlobalStates.anyAmbientActive) {
                            ambientShowAnim.stop();
                            ambientHideAnim.start();
                        } else {
                            ambientHideAnim.stop();
                            widget.ambientShimmerOpacity = 0;
                            widget.ambientShimmerPos = -0.3;
                            ambientShowAnim.start();
                        }
                    }
                }
            }
        }
    }
}

