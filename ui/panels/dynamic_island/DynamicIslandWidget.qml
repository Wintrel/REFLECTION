import QtQuick
import "../../components"
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import QtMultimedia
import "../../../core" as Core
import "../../../core/state" as State
import "../../../core/services/system"
import "../../../core/services/media"
import "../../components" as Components
import "./components" as IslandComponents

Item {
    id: islandWidget
    
    Core.Theme { id: theme }

    // Dynamically bind the container size to exactly the visible bounding box of the island
    width: theme.floatingIsland ? islandShape.width : (islandShape.width + (2 * theme.radiusIsland))
    height: theme.floatingIsland ? islandShape.height : (islandShape.height - theme.radiusIsland)
    
    onHeightChanged: {
        State.GlobalStates.currentIslandHeight = height;
    }
    
    DynamicIslandController {
        id: controller
    }

    // Proxy properties so the rest of the UI doesn't break
    property alias islandState: controller.islandState
    property alias previousState: controller.previousState
    property alias isLocked: controller.isLocked
    property alias osdMode: controller.osdMode
    property alias osdPriority: controller.osdPriority
    property alias osdIcon: controller.osdIcon
    property alias osdText: controller.osdText
    property alias osdColor: controller.osdColor
    property alias mprisPlayer: controller.mprisPlayer
    property alias currentNotif: controller.currentNotif

    // Ambient hide animation properties (driven by DynamicIsland.qml).
    property real ambientShimmerPos: -0.3
    property real ambientShimmerOpacity: 0
    

    function dismissNotification() {
        controller.dismissNotification();
    }
    
    function cyclePlayer() {
        CiderService.cycleFallbackPlayer();
    }

    // Debug & Timing utilities for transition testing
    property real transitionStartTime: 0
    property int lastState: -1

    function getStateName(st) {
        switch (st) {
            case State.IslandState.idle: return "idle";
            case State.IslandState.hover: return "hover";
            case State.IslandState.expanded: return "expanded";
            case State.IslandState.notification: return "notification";
            case State.IslandState.notificationHistory: return "notificationHistory";
            case State.IslandState.osd: return "osd";
            case State.IslandState.prompt: return "prompt";
            case State.IslandState.actionProgress: return "actionProgress";
            case State.IslandState.reflectionGrid: return "reflectionGrid";
            case State.IslandState.battery: return "battery";
            case State.IslandState.polkitAuth: return "polkitAuth";
            case State.IslandState.settingsHub: return "settingsHub";
            case State.IslandState.filePicker: return "filePicker";
            case State.IslandState.ciderExpanded: return "ciderExpanded";
            case State.IslandState.clipboard: return "clipboard";
            default: return "state(" + st + ")";
        }
    }

    onIslandStateChanged: {
        var now = Date.now();
        var fromName = getStateName(lastState);
        var toName = getStateName(islandState);
        transitionStartTime = now;
        console.log("[DynamicIsland DEBUG] State swap triggered: " + fromName + " -> " + toName + " (t=" + now + "ms)");
        lastState = islandState;
    }

    // Outer Frosty Glow
    RectangularGlow {
        anchors.fill: islandShape
        glowRadius: theme.floatingIsland ? 18 : 20
        spread: theme.floatingIsland ? 0.08 : 0.05
        color: theme.accentPrimary
        cornerRadius: islandShape.radius + glowRadius
        
        property bool isActive: islandWidget.islandState !== State.IslandState.idle
        opacity: isActive ? (theme.floatingIsland ? 0.38 : 0.32) : (theme.floatingIsland ? 0.08 : 0.0)
        Behavior on opacity { NumberAnimation { duration: theme.durationMorph; easing.type: theme.easingStandard } }
        Behavior on color { ColorAnimation { duration: 300 } }
    }

    // Super+I hold feedback. The edge charges continuously toward the
    // immersive threshold and hands its energy to the Reflection bloom.
    RectangularGlow {
        anchors.fill: islandShape
        visible: BehaviorService.holdFeedbackEnabled && State.GlobalStates.settingsHoldProgress > 0
        glowRadius: 8 + State.GlobalStates.settingsHoldProgress * 12 * ShellService.holdIndicatorIntensity
        spread: 0.04 + State.GlobalStates.settingsHoldProgress * 0.08 * ShellService.holdIndicatorIntensity
        color: theme.accentPrimary
        cornerRadius: islandShape.radius + glowRadius
        opacity: State.GlobalStates.settingsHoldProgress * 0.38 * ShellService.holdIndicatorIntensity
    }

    // The actual island container (Outer Bezel)
    Rectangle {
        id: islandShape
        property alias mouseArea: ma
        
        // Mouse area to trigger expansion
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            
            onEntered: {
                controller.isHovered = true;
                if (islandWidget.isLocked || islandWidget.islandState === State.IslandState.clipboard || islandWidget.islandState === State.IslandState.settingsHub || islandWidget.islandState === State.IslandState.filePicker || islandWidget.islandState === State.IslandState.reflectionGrid || islandWidget.islandState === State.IslandState.polkitAuth || islandWidget.islandState === State.IslandState.prompt || islandWidget.islandState === State.IslandState.actionProgress) return;
                if (islandWidget.islandState === State.IslandState.notification) controller.stopTimers();
                else if (islandWidget.islandState === State.IslandState.osd) controller.stopTimers();
                else if (islandWidget.islandState !== State.IslandState.expanded && islandWidget.islandState !== State.IslandState.notificationHistory && islandWidget.islandState !== State.IslandState.battery && islandWidget.islandState !== State.IslandState.ciderExpanded) islandWidget.islandState = State.IslandState.hover
            }
            onExited: {
                controller.isHovered = false;
                if (islandWidget.isLocked || islandWidget.islandState === State.IslandState.clipboard || islandWidget.islandState === State.IslandState.settingsHub || islandWidget.islandState === State.IslandState.filePicker || islandWidget.islandState === State.IslandState.reflectionGrid || islandWidget.islandState === State.IslandState.polkitAuth || islandWidget.islandState === State.IslandState.prompt || islandWidget.islandState === State.IslandState.actionProgress) return;
                if (islandWidget.islandState === State.IslandState.notification) controller.restartTimers();
                else if (islandWidget.islandState === State.IslandState.osd) controller.restartTimers();
                else if (islandWidget.islandState !== State.IslandState.expanded && islandWidget.islandState !== State.IslandState.notificationHistory && islandWidget.islandState !== State.IslandState.battery && islandWidget.islandState !== State.IslandState.ciderExpanded) islandWidget.islandState = State.IslandState.idle
            }
            onClicked: {
                if (islandWidget.isLocked || islandWidget.islandState === State.IslandState.reflectionGrid || islandWidget.islandState === State.IslandState.polkitAuth || islandWidget.islandState === State.IslandState.prompt || islandWidget.islandState === State.IslandState.actionProgress) return;
                
                if (islandWidget.islandState === State.IslandState.clipboard) {
                    State.GlobalStates.clipboardOpen = false;
                    return;
                }
                if (islandWidget.islandState === State.IslandState.filePicker) {
                    State.GlobalStates.closeFilePicker();
                    return;
                }
                if (islandWidget.islandState === State.IslandState.settingsHub) {
                    State.GlobalStates.settingsOpen = false;
                    return;
                }
                if (islandWidget.islandState === State.IslandState.notification) {
                    if (islandWidget.previousState === State.IslandState.expanded || islandWidget.previousState === State.IslandState.notificationHistory || islandWidget.previousState === State.IslandState.battery) {
                        islandWidget.islandState = islandWidget.previousState;
                    } else {
                        islandWidget.islandState = State.IslandState.hover;
                    }
                    if (islandWidget.currentNotif) {
                        islandWidget.currentNotif.close();
                    }
                    islandWidget.previousState = State.IslandState.idle;
                } else if (islandWidget.islandState === State.IslandState.notificationHistory) {
                    islandWidget.islandState = State.IslandState.idle;
                } else if (islandWidget.islandState === State.IslandState.expanded || islandWidget.islandState === State.IslandState.battery || islandWidget.islandState === State.IslandState.ciderExpanded) {
                    islandWidget.islandState = containsMouse ? State.IslandState.hover : State.IslandState.idle
                } else {
                    islandWidget.islandState = State.IslandState.expanded
                }
            }
        }
        

        // Center horizontally in the widget
        anchors.horizontalCenter: parent.horizontalCenter
        
        // Position negatively to hide the top rounded corners when docked
        y: theme.floatingIsland ? 0 : -theme.radiusIsland
        
        // Smooth sizing based on state
        width: {
            if (islandState === State.IslandState.reflectionGrid) {
                if (reflectionContent.currentIntent === 3) return theme.reflectionAssistantW; // Assistant
                if (State.ReflectionState.searchQuery.length === 0) return theme.reflectionSearchW; // Search bar only
                if (reflectionContent.currentIntent === 0) return theme.reflectionGridW; // App Grid
                return theme.reflectionFocusW; // Math / Command Intents
            }
            if (islandState === State.IslandState.clipboard) return theme.islandClipboardW; // Clipboard
            if (islandState === State.IslandState.ciderExpanded) return theme.islandCiderW; // Cider Ultra Expanded
            if (islandState === State.IslandState.filePicker) return theme.islandFilePickerW; // File Picker
            if (islandState === State.IslandState.settingsHub) return theme.islandSettingsW; // Settings Hub
            if (islandState === State.IslandState.polkitAuth) return theme.islandMaxW; // Polkit Auth
            if (islandState === State.IslandState.actionProgress) return theme.islandProgressW; // Action Progress
            if (islandState === State.IslandState.prompt) return theme.islandMaxW; // Prompt
            if (islandState === State.IslandState.osd) return theme.islandHoverW;
            if (islandState === State.IslandState.notificationHistory) return theme.islandHistoryW;
            if (islandState === State.IslandState.notification) return theme.islandNotifW;
            if (islandState === State.IslandState.battery) return theme.islandBatteryW;
            if (islandState === State.IslandState.expanded) return theme.islandMaxW;
            if (islandState === State.IslandState.hover) return theme.islandHoverW;
            
            var hasM = ShellService.islandMediaActivity && islandWidget.mprisPlayer && islandWidget.mprisPlayer.isPlaying;
            var hasN = ShellService.islandNotificationPreviews && State.GlobalStates.notificationHistory.count > 0;
            if (ShellService.islandIdleMode === 0) return 120;
            if (ShellService.islandIdleMode === 2) return theme.islandMinW;
            return (hasM || hasN) ? theme.islandMinW : 120;
        }
        height: {
            var targetH = theme.islandMinH;
            if (islandState === State.IslandState.reflectionGrid) {
                if (reflectionContent.currentIntent === 3) targetH = theme.reflectionAssistantH; // Assistant
                else if (State.ReflectionState.searchQuery.length === 0) targetH = theme.reflectionSearchH; // Search bar only
                else if (reflectionContent.currentIntent === 0) targetH = theme.reflectionGridH; // App Grid
                else targetH = theme.reflectionFocusH; // Math / Command Intents
            }
            else if (islandState === State.IslandState.clipboard) targetH = theme.islandClipboardH; // Clipboard
            else if (islandState === State.IslandState.ciderExpanded) targetH = theme.islandCiderH; // Cider Ultra Expanded
            else if (islandState === State.IslandState.filePicker) targetH = theme.islandFilePickerH; // File Picker
            else if (islandState === State.IslandState.settingsHub) targetH = theme.islandSettingsH; // Settings Hub
            else if (islandState === State.IslandState.polkitAuth) targetH = theme.islandMaxH; // Polkit Auth
            else if (islandState === State.IslandState.actionProgress) targetH = theme.islandProgressH; // Action Progress
            else if (islandState === State.IslandState.prompt) targetH = theme.islandMaxH; // Prompt
            else if (islandState === State.IslandState.osd) targetH = theme.islandHoverH;
            else if (islandState === State.IslandState.notificationHistory) targetH = historyContent.computedHeight;
            else if (islandState === State.IslandState.notification) targetH = theme.islandNotifH;
            else if (islandState === State.IslandState.battery) targetH = theme.islandBatteryH;
            else if (islandState === State.IslandState.expanded) targetH = theme.islandMaxH;
            else if (islandState === State.IslandState.hover) targetH = theme.islandHoverH;
            return targetH + (theme.floatingIsland ? 0 : theme.radiusIsland);
        }
        
        radius: {
            if (!theme.floatingIsland) return theme.radiusIsland;
            if (islandState === State.IslandState.idle) {
                return Math.round(theme.islandMinH / 2);
            }
            if (islandState === State.IslandState.hover || islandState === State.IslandState.osd) {
                return Math.round(theme.islandHoverH / 2);
            }
            return theme.radiusIslandFloating;
        }
        color: theme.bgBezel
        
        // Glass edge look (1px frosty border)
        border.width: theme.islandBorderWidth > 0 ? 1 : 0
        border.color: islandWidget.islandState !== State.IslandState.idle 
                      ? Qt.rgba(theme.colorSystemShimmer.r, theme.colorSystemShimmer.g, theme.colorSystemShimmer.b, 0.4)
                      : "transparent"
        
        Behavior on border.color { ColorAnimation { duration: theme.durationMorph; easing.type: theme.easingStandard } }
        
        Behavior on width {
            NumberAnimation {
                id: widthAnim
                duration: theme.durationMorph
                easing.type: theme.easingMorph
                easing.overshoot: theme.morphOvershoot !== undefined ? theme.morphOvershoot : 0.35
            }
        }
        
        Behavior on height {
            NumberAnimation {
                id: heightAnim
                duration: theme.durationMorph
                easing.type: theme.easingMorph
                easing.overshoot: theme.morphOvershoot !== undefined ? theme.morphOvershoot : 0.35
            }
        }

        Behavior on radius {
            NumberAnimation {
                id: radiusAnim
                duration: theme.durationMorph
                easing.type: theme.easingMorph
                easing.overshoot: theme.morphOvershoot !== undefined ? theme.morphOvershoot : 0.35
            }
        }

        scale: (ma.pressed && !islandWidget.isLocked) ? 0.98 : (controller.isHovered && islandWidget.islandState === State.IslandState.idle ? 1.015 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuad
            }
        }

        property bool isAnimating: widthAnim.running || heightAnim.running || radiusAnim.running
        onIsAnimatingChanged: {
            if (isAnimating) {
                console.log("[DynamicIsland DEBUG] Animation started -> target size: " + Math.round(islandShape.width) + "x" + Math.round(islandShape.height));
            } else if (islandWidget.transitionStartTime > 0) {
                var duration = Date.now() - islandWidget.transitionStartTime;
                console.log("[DynamicIsland DEBUG] Transition completed in " + duration + "ms (" + islandWidget.getStateName(islandWidget.islandState) + ") -> final size: " + Math.round(islandShape.width) + "x" + Math.round(islandShape.height));
            }
        }
        
        // The inner inset content area
        Item {
            id: innerShape
            anchors.fill: parent
            anchors.leftMargin: theme.islandBorderWidth
            anchors.rightMargin: theme.islandBorderWidth
            anchors.bottomMargin: theme.islandBorderWidth
            anchors.topMargin: theme.floatingIsland ? theme.islandBorderWidth : (theme.radiusIsland + 4)
            clip: true
            
            Item {
                id: innerMask
                anchors.fill: parent
                layer.enabled: true
                z: -1
                
                Rectangle {
                    anchors.fill: parent
                    radius: Math.max(0, islandShape.radius - theme.islandBorderWidth)
                    color: theme.bgInner
                }
                
                // Square off top corners to seamlessly connect to the black bezel above (docked mode only)
                Rectangle {
                    visible: !theme.floatingIsland
                    height: islandShape.radius
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: theme.bgInner
                }
            }
            
            ReflectionGradient {
                theme: theme
                startColor: theme.bgInner
                endColor: theme.bgInnerGradientEnd
                anchors.fill: parent
                source: innerMask
                z: -1
            }
            
            IslandComponents.MinimizedContent {
                anchors.fill: parent
                islandState: islandWidget.islandState
                mprisPlayer: islandWidget.mprisPlayer
                theme: theme
            }
            
            IslandComponents.ExpandedContent {
                islandState: islandWidget.islandState
                mprisPlayer: islandWidget.mprisPlayer
                theme: theme
                islandMaxW: theme.islandMaxW
                islandMaxH: theme.islandMaxH
            }
            
            IslandComponents.NotificationContent {
                islandState: islandWidget.islandState
                theme: theme
                islandNotifW: theme.islandNotifW
                islandNotifH: theme.islandNotifH
                currentNotif: islandWidget.currentNotif
                isLocked: islandWidget.isLocked
                onDismissRequested: islandWidget.dismissNotification()
            }
            
            IslandComponents.NotificationHistoryContent {
                id: historyContent
                islandState: islandWidget.islandState
                theme: theme
                mprisPlayer: islandWidget.mprisPlayer
                islandHistoryW: theme.islandHistoryW
                islandHistoryH: theme.islandHistoryH
            }
            
            IslandComponents.OsdContent {
                islandState: islandWidget.islandState
                osdMode: islandWidget.osdMode
                osdPriority: islandWidget.osdPriority
                osdIcon: islandWidget.osdIcon
                osdText: islandWidget.osdText
                osdColor: islandWidget.osdColor
                theme: theme
                islandHoverW: theme.islandHoverW
                islandHoverH: theme.islandHoverH
            }

            IslandComponents.PromptContent {
                islandState: islandWidget.islandState
                theme: theme
                islandMaxW: theme.islandMaxW
                islandMaxH: theme.islandMaxH
            }
            
            IslandComponents.PolkitAuthContent {
                islandState: islandWidget.islandState
                theme: theme
                islandMaxW: theme.islandMaxW
                islandMaxH: theme.islandMaxH
            }
            
            IslandComponents.ActionProgressContent {
                islandState: islandWidget.islandState
                theme: theme
                islandMaxW: theme.islandProgressW
                islandMaxH: theme.islandProgressH
            }

            IslandComponents.ReflectionContent {
                id: reflectionContent
                islandState: islandWidget.islandState
                theme: theme
            }
            
            IslandComponents.SettingsContent {
                id: settingsContent
                islandState: islandWidget.islandState
                theme: theme
            }
            
            IslandComponents.FilePicker {
                id: filePickerContent
                islandState: islandWidget.islandState
                theme: theme
            }

            IslandComponents.BatteryContent {
                islandState: islandWidget.islandState
                theme: theme
                islandBatteryW: theme.islandBatteryW
                islandBatteryH: theme.islandBatteryH
            }

            IslandComponents.CiderHubContent {
                islandState: islandWidget.islandState
                mprisPlayer: islandWidget.mprisPlayer
                theme: theme
                islandCiderW: theme.islandCiderW
                islandCiderH: theme.islandCiderH
            }

            IslandComponents.ClipboardContent {
                islandState: islandWidget.islandState
                theme: theme
                islandClipboardW: theme.islandClipboardW
                islandClipboardH: theme.islandClipboardH
            }

            // Ambient hide shimmer sweep overlay
            Item {
                anchors.fill: parent
                opacity: islandWidget.ambientShimmerOpacity
                visible: opacity > 0
                z: 100

                Rectangle {
                    height: parent.height
                    width: parent.width * 0.35
                    x: islandWidget.ambientShimmerPos * (parent.width + width) - width * 0.5

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.35; color: Qt.rgba(0.0, 0.32, 1.0, 0.2) }
                        GradientStop { position: 0.5; color: Qt.rgba(0.0, 0.32, 1.0, 0.35) }
                        GradientStop { position: 0.65; color: Qt.rgba(0.0, 0.32, 1.0, 0.2) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            // A centre-out charging seam gives the short hold a readable
            // direction without resizing the island or replacing its content.
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: islandShape.radius
                anchors.rightMargin: islandShape.radius
                anchors.bottomMargin: 1
                height: 3
                z: 200
                visible: State.GlobalStates.settingsHoldProgress > 0

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * State.GlobalStates.settingsHoldProgress
                    height: 2
                    radius: 1
                    color: theme.accentPrimary
                    opacity: (0.45 + State.GlobalStates.settingsHoldProgress * 0.55) * ShellService.holdIndicatorIntensity
                }
            }

        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1.5
            border.color: theme.accentPrimary
            opacity: State.GlobalStates.settingsHoldProgress > 0
                ? (0.12 + State.GlobalStates.settingsHoldProgress * 0.76) * ShellService.holdIndicatorIntensity
                : 0
            z: 199
        }
    }
    
    IslandComponents.IslandFillets {
        visible: !theme.floatingIsland
        islandShape: islandShape
        radiusIsland: theme.radiusIsland
        bgBezel: theme.bgBezel
        
        isActive: islandWidget.islandState !== State.IslandState.idle
        glowColor: theme.accentPrimary
        shimmerColor: Qt.rgba(theme.colorSystemShimmer.r, theme.colorSystemShimmer.g, theme.colorSystemShimmer.b, 0.4)
        borderWidth: theme.islandBorderWidth
        animDuration: theme.durationMorph
    }

    // Global Wayland Shortcut Hook for Super key1
    GlobalShortcut {
        name: "quickshell:searchToggleRelease"
        onPressed: {
            State.ReflectionState.toggle()
        }
    }

    // IPC Handler Hook for hyprctl or quickshell IPC
    IpcHandler {
        target: "searchToggle"
        function trigger() {
            State.ReflectionState.toggle()
        }
    }

    GlobalShortcut {
        name: "quickshell:mediaControlsToggle"
        onPressed: {
            if (islandWidget.islandState === State.IslandState.expanded || islandWidget.islandState === State.IslandState.ciderExpanded) {
                islandWidget.islandState = State.IslandState.idle;
            } else {
                islandWidget.islandState = State.IslandState.expanded;
            }
        }
    }

    IpcHandler {
        target: "media"
        function toggle() {
            if (islandWidget.islandState === State.IslandState.expanded || islandWidget.islandState === State.IslandState.ciderExpanded) {
                islandWidget.islandState = State.IslandState.idle;
            } else {
                islandWidget.islandState = State.IslandState.expanded;
            }
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle() {
            if (islandWidget.islandState === State.IslandState.notificationHistory) {
                islandWidget.islandState = State.IslandState.idle;
            } else {
                islandWidget.islandState = State.IslandState.notificationHistory;
            }
        }
    }
}
