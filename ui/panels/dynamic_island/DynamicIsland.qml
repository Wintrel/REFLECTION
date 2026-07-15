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

            WlrLayershell.keyboardFocus: (widget.islandState === 6 || widget.islandState === 8 || widget.islandState === 10) ? WlrKeyboardFocus.Exclusive : ((widget.islandState === 11 || widget.islandState === 12 || widget.islandState === 13) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)
            
            // Anchor only to the top, so it centers horizontally by default
            anchors {
                top: true
            }
            
            // Make sure the window acts as an overlay and doesn't take up literal screen space
            exclusiveZone: 0
            
            // Transparent background for the panel itself
            color: "transparent"
            
            // Lock the Wayland surface size to the maximum possible bounds to prevent resizing wobble
            implicitWidth: Math.max(theme.islandMaxW, theme.islandHistoryW || 0, theme.reflectionGridW || 800, theme.islandSettingsW || 800, theme.islandCiderW || 0, theme.islandFilePickerW || 1000) + (2 * theme.radiusIsland)
            implicitHeight: Math.max(theme.islandMaxH, theme.islandHistoryH || 0, theme.reflectionGridH || 600, theme.islandSettingsH || 600, theme.islandCiderH || 0, theme.islandFilePickerH || 600) + theme.radiusIsland
            
            // Mask the input/visual region exactly to the opaque pixels of the container
            // This perfectly prevents the window from blocking clicks on the desktop!
            mask: Region {
                item: widget
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
