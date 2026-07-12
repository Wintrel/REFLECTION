import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../../core" as Core
import "../../../core/state" as State
import "../../../core/services/system"
import "../../../core/monitors"
import "../../components" as Components

Scope {
    Variants {
        model: Quickshell.screens
        
        delegate: PanelWindow {
            id: idleWindow
            required property var modelData
            screen: modelData

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            
            // Allow this window to overlay everything without shifting the desktop layout
            exclusiveZone: 0
            
            // Put it just under normal OS overlays but above the wallpaper/desktop
            WlrLayershell.layer: WlrLayer.Top
            
            // The window itself is transparent and only visible when the content is
            color: "transparent"
            visible: contentOverlay.opacity > 0
            
            // Vignette overlay
            Item {
                id: contentOverlay
                anchors.fill: parent

                opacity: State.GlobalStates.anyAmbientActive ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutSine } }

                RadialGradient {
                    anchors.fill: parent
                    horizontalRadius: Math.sqrt(width * width / 4 + height * height / 4)
                    verticalRadius: Math.sqrt(width * width / 4 + height * height / 4)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.65) }
                        GradientStop { position: 0.55; color: Qt.rgba(0, 0, 0, 0.85) }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.98) }
                    }
                }
                


                Components.Starfield {
                    anchors.fill: parent
                    // Slightly lower density for background stars to make raining stars stand out
                    starCount: 120
                    opacity: 0.4
                    starColor: "#FFFFFF"
                }

                Components.FallingStars {
                    anchors.fill: parent
                    visible: contentOverlay.opacity > 0
                }
                
                // Capture keyboard input to wake the shell
                FocusScope {
                    anchors.fill: parent
                    focus: State.GlobalStates.anyAmbientActive
                    Keys.onPressed: (event) => {
                        State.GlobalStates.ambientIdleActive = false;
                        State.GlobalStates.ambientActiveMode = false;
                        event.accepted = true;
                    }
                }
                
                // Capture mouse movement/clicks to wake the shell
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPositionChanged: {
                        // Slight debounce so it doesn't wake instantly if the mouse was already moving when triggered
                        if (State.GlobalStates.anyAmbientActive && contentOverlay.opacity > 0.5) {
                            State.GlobalStates.ambientIdleActive = false;
                            State.GlobalStates.ambientActiveMode = false;
                        }
                    }
                    onPressed: {
                        State.GlobalStates.ambientIdleActive = false;
                        State.GlobalStates.ambientActiveMode = false;
                    }
                }
                }
            
            // Bottom Ambient Visualizer.
            Item {
                width: parent.width
                height: 100
                anchors.bottom: parent.bottom
                
                Components.IdleVisualizer {
                    anchors.fill: parent
                    anchors.bottomMargin: 10
                    visible: State.GlobalStates.ambientIdleActive
                }
                
                Components.MusicVisualizer {
                    anchors.fill: parent
                    anchors.bottomMargin: 10
                    visible: State.GlobalStates.ambientActiveMode
                    isPlaying: true
                    accentColor: '#6c0011ff' // Matches the charging cyan electric blue style
                }
            }
        } // end PanelWindow
    } // end Variants
} // end Scope
