import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../core" as Core
import "../../../core/monitors"
import "../../../core/state" as State
import "../../../core/services/system"
import "../../../core/services/ai"
import "./components" as IslandComponents

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
            

            
            // Immersive mode reserves a top lane for the island. Raise the
            // island's surface so system-critical states such as Polkit can
            // never be hidden behind the fullscreen settings surface.
            WlrLayershell.layer: (State.GlobalStates.islandInOverlay || State.GlobalStates.immersivePhase !== State.GlobalStates.immersiveClosed || State.GlobalStates.assistantWorkspaceOpen)
                ? WlrLayer.Overlay
                : WlrLayer.Top
            
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
                Region {
                    item: batteryOrb
                }
                Region {
                    item: progressOrb
                }
                Region {
                    item: mediaOrb
                }
                Region {
                    item: aiAuraOrb
                }
                Region {
                    item: immersiveBloom
                }
            }

            // Reflection bloom — a layered wave originating at the island.
            // The solid inner disc hides the layer-shell handoff; the two
            // translucent discs create a soft accent leading edge without a
            // shader, which keeps the effect predictable across GPUs.
            Item {
                id: immersiveBloom
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: running ? parent.height : 0
                visible: running
                clip: false
                z: 10

                property bool running: false
                property real progress: 0
                property real bloomOpacity: 0
                readonly property real originX: width / 2
                readonly property real originY: Math.max(20, (theme.floatingIsland ? theme.islandTopMargin : 0) + widget.height / 2)
                readonly property real maximumDiameter: Math.sqrt(width * width + (height * 2) * (height * 2)) * 1.12

                opacity: bloomOpacity

                Rectangle {
                    // Keep geometry fixed and animate only the transform. This
                    // avoids rebuilding a very large rounded rectangle every
                    // frame as the bloom approaches fullscreen size.
                    width: immersiveBloom.maximumDiameter + 150
                    height: width
                    x: immersiveBloom.originX - width / 2
                    y: immersiveBloom.originY - height / 2
                    radius: width / 2
                    transformOrigin: Item.Center
                    scale: (immersiveBloom.maximumDiameter * immersiveBloom.progress + 150) / width
                    color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.035) : Qt.rgba(0.35, 0.35, 0.8, 0.035)
                }

                Rectangle {
                    width: immersiveBloom.maximumDiameter + 72
                    height: width
                    x: immersiveBloom.originX - width / 2
                    y: immersiveBloom.originY - height / 2
                    radius: width / 2
                    transformOrigin: Item.Center
                    scale: (immersiveBloom.maximumDiameter * immersiveBloom.progress + 72) / width
                    color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.085) : Qt.rgba(0.35, 0.35, 0.8, 0.085)
                }

                Rectangle {
                    width: immersiveBloom.maximumDiameter
                    height: width
                    x: immersiveBloom.originX - width / 2
                    y: immersiveBloom.originY - height / 2
                    radius: width / 2
                    transformOrigin: Item.Center
                    scale: immersiveBloom.progress
                    color: theme ? theme.bgBase : "#0A0A0C"
                    border.width: immersiveBloom.progress > 0.03 && immersiveBloom.progress < 0.97 ? 2 : 0
                    border.color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.58) : Qt.rgba(0.45, 0.45, 1, 0.58)
                }

                MouseArea {
                    anchors.fill: parent
                    // Block interaction with either surface during the handoff.
                }
            }

            SequentialAnimation {
                id: bloomOpenAnimation

                ScriptAction {
                    script: {
                        immersiveBloom.running = true;
                        immersiveBloom.progress = 0;
                        immersiveBloom.bloomOpacity = 1;
                    }
                }
                ParallelAnimation {
                    SequentialAnimation {
                        NumberAnimation {
                            target: widget
                            property: "scale"
                            to: 0.96
                            duration: 70
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: widget
                            property: "scale"
                            to: 1
                            duration: 180
                            easing.type: Easing.OutBack
                        }
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 55 }
                        NumberAnimation {
                            target: immersiveBloom
                            property: "progress"
                            from: 0
                            to: 1
                            duration: 505
                            easing.type: Easing.InOutCubic
                        }
                    }
                }

                // Do not map or render settings while the wave itself is
                // moving. Once the opaque core covers the output, activate the
                // fullscreen surface behind it and give the scene graph time
                // to upload images, compile effects, and finish its entrance.
                ScriptAction { script: State.GlobalStates.immersiveOpen = true }
                PauseAnimation { duration: 340 }
                NumberAnimation {
                    target: immersiveBloom
                    property: "bloomOpacity"
                    to: 0
                    duration: 210
                    easing.type: Easing.OutQuad
                }
                ScriptAction {
                    script: {
                        immersiveBloom.running = false;
                        immersiveBloom.progress = 0;
                        State.GlobalStates.immersivePhase = State.GlobalStates.immersiveOpened;
                    }
                }
            }

            SequentialAnimation {
                id: bloomCloseAnimation

                ScriptAction {
                    script: {
                        immersiveBloom.running = true;
                        immersiveBloom.progress = 1;
                        immersiveBloom.bloomOpacity = 0;
                    }
                }
                NumberAnimation {
                    target: immersiveBloom
                    property: "bloomOpacity"
                    to: 1
                    duration: 160
                    easing.type: Easing.InQuad
                }
                ScriptAction { script: State.GlobalStates.immersiveOpen = false }
                PauseAnimation { duration: 55 }
                NumberAnimation {
                    target: immersiveBloom
                    property: "progress"
                    from: 1
                    to: 0
                    duration: 500
                    easing.type: Easing.InOutCubic
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: immersiveBloom
                        property: "bloomOpacity"
                        to: 0
                        duration: 90
                    }
                    SequentialAnimation {
                        NumberAnimation {
                            target: widget
                            property: "scale"
                            to: 1.04
                            duration: 70
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: widget
                            property: "scale"
                            to: 1
                            duration: 160
                            easing.type: Easing.OutBack
                        }
                    }
                }
                ScriptAction {
                    script: {
                        immersiveBloom.running = false;
                        immersiveBloom.progress = 0;
                        State.GlobalStates.immersivePhase = State.GlobalStates.immersiveClosed;
                    }
                }
            }

            Connections {
                target: State.GlobalStates

                function onImmersivePhaseChanged() {
                    // Promoting a layer-shell surface from Top to Overlay is
                    // applied asynchronously. Launch on the next event-loop
                    // turn so the first bloom frame is drawn on the new layer.
                    bloomLaunchTimer.restart();
                }
            }

            Timer {
                id: bloomLaunchTimer
                interval: 16
                repeat: false

                onTriggered: {
                    if (State.GlobalStates.immersivePhase === State.GlobalStates.immersiveOpening) {
                        bloomCloseAnimation.stop();
                        bloomOpenAnimation.start();
                    } else if (State.GlobalStates.immersivePhase === State.GlobalStates.immersiveClosing) {
                        bloomOpenAnimation.stop();
                        bloomCloseAnimation.start();
                    }
                }
            }
            
            DynamicIslandWidget {
                id: widget
                z: 20
                anchors.horizontalCenter: parent.horizontalCenter
                
                anchors.top: parent.top
                anchors.topMargin: theme.floatingIsland ? theme.islandTopMargin : 0

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
                        to: (theme.floatingIsland ? theme.islandTopMargin : 0) + 3
                        duration: 150
                        easing.type: Easing.OutQuad
                    }

                    // Phase 3: Slide away behind the screen edge
                    NumberAnimation {
                        target: widget
                        property: "anchors.topMargin"
                        to: -widget.height - (theme.floatingIsland ? theme.islandTopMargin + 20 : 20)
                        duration: 500
                        easing.type: Easing.InOutCubic
                    }
                }

                // Ambient show: smooth slide back into view
                NumberAnimation {
                    id: ambientShowAnim
                    target: widget
                    property: "anchors.topMargin"
                    to: theme.floatingIsland ? theme.islandTopMargin : 0
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

            // Companion Battery Orb (Right Side)
            IslandComponents.BatteryOrb {
                id: batteryOrb
                z: 19
                theme: theme
                targetWidget: widget
                onExpandRequested: {
                    widget.islandState = State.IslandState.battery;
                }
            }

            // Companion Progress Orb (Right Side - pops out during system actions & tasks)
            IslandComponents.ProgressOrb {
                id: progressOrb
                z: 19
                theme: theme
                targetWidget: widget
                rightNeighbor: batteryOrb
                onExpandRequested: {
                    widget.islandState = State.IslandState.actionProgress;
                }
            }

            // Companion Media Orb (Left Side - pops out when music plays and island displays other states)
            IslandComponents.MediaOrb {
                id: mediaOrb
                z: 19
                theme: theme
                targetWidget: widget
                mprisPlayer: widget.mprisPlayer
                active: {
                    var isPlaying = widget.mprisPlayer && widget.mprisPlayer.isPlaying;
                    var isMainShowingOther = widget.islandState !== State.IslandState.idle && 
                                            widget.islandState !== State.IslandState.hover && 
                                            widget.islandState !== State.IslandState.expanded && 
                                            widget.islandState !== State.IslandState.ciderExpanded;
                    return isPlaying && isMainShowingOther;
                }
                onExpandRequested: {
                    widget.islandState = State.IslandState.expanded;
                }
            }

            // Companion AI Aura Orb (Left Side - pops out when AI is thinking / generating)
            IslandComponents.AiAuraOrb {
                id: aiAuraOrb
                z: 19
                theme: theme
                targetWidget: widget
                leftNeighbor: mediaOrb
            }

            // Automatic Triggers for Action Progress Events
            Connections {
                target: ActionProgressService
                function onActionRequested() {
                    progressOrb.trigger();
                }
                function onInProgressChanged() {
                    if (ActionProgressService.inProgress) {
                        progressOrb.trigger();
                    }
                }
            }

            // Automatic Triggers for AI Generation Events
            Connections {
                target: AiDaemonService
                function onIsGeneratingChanged() {
                    if (AiDaemonService.isGenerating) {
                        aiAuraOrb.trigger();
                    }
                }
                function onGenerationFinished() {
                    aiAuraOrb.trigger();
                }
                function onGenerationError() {
                    aiAuraOrb.trigger();
                }
            }

            // Automatic Triggers for Battery Events
            Connections {
                target: BatteryService
                function onIsChargingChanged() {
                    batteryOrb.trigger();
                }
                function onIsOnACChanged() {
                    batteryOrb.trigger();
                }
                function onIsOneshotChargingChanged() {
                    if (BatteryService.isOneshotCharging) {
                        batteryOrb.trigger();
                    } else {
                        batteryOrb.dismiss();
                    }
                }
            }
        }
    }
}
