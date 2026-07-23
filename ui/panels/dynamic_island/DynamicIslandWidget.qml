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
    width: islandShape.width + (2 * theme.radiusIsland)
    height: islandShape.height - theme.radiusIsland
    
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

    // Ambient hide animation properties (driven by DynamicIsland.qml)
    property real ambientShimmerPos: -0.3
    property real ambientShimmerOpacity: 0
    
    function dismissNotification() {
        controller.dismissNotification();
    }
    
    function cyclePlayer() {
        CiderService.cycleFallbackPlayer();
    }

    // Outer Frosty Glow
    RectangularGlow {
        anchors.fill: islandShape
        glowRadius: 16
        spread: 0.1
        color: theme.accentPrimary
        cornerRadius: islandShape.radius + glowRadius
        
        property bool isActive: islandWidget.islandState !== State.IslandState.idle
        opacity: isActive ? 0.25 : 0.0
        Behavior on opacity { NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutSine } }
        Behavior on color { ColorAnimation { duration: 300 } }
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
        
        // Position negatively to hide the top rounded corners
        y: -theme.radiusIsland
        
        // Smooth sizing based on state
        width: {
            if (islandState === State.IslandState.reflectionGrid) {
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
            
            var hasM = islandWidget.mprisPlayer && islandWidget.mprisPlayer.isPlaying;
            var hasN = State.GlobalStates.notificationHistory.count > 0;
            return (hasM || hasN) ? theme.islandMinW : 120;
        }
        height: {
            var targetH = theme.islandMinH;
            if (islandState === State.IslandState.reflectionGrid) {
                if (State.ReflectionState.searchQuery.length === 0) targetH = theme.reflectionSearchH; // Search bar only
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
            return targetH + theme.radiusIsland;
        }
        
        radius: theme.radiusIsland
        color: theme.bgBezel
        
        // Glass edge look (1px frosty border)
        border.width: theme.islandBorderWidth > 0 ? 1 : 0
        border.color: Qt.rgba(theme.colorSystemShimmer.r, theme.colorSystemShimmer.g, theme.colorSystemShimmer.b, 0.4)
        
        Behavior on width {
            NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo }
        }
        
        Behavior on height {
            NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo }
        }
        
        // The inner inset content area
        Item {
            id: innerShape
            anchors.fill: parent
            anchors.leftMargin: theme.islandBorderWidth
            anchors.rightMargin: theme.islandBorderWidth
            anchors.bottomMargin: theme.islandBorderWidth
            anchors.topMargin: theme.radiusIsland + 4
            clip: true
            
            Item {
                id: innerMask
                anchors.fill: parent
                layer.enabled: true
                z: -1
                
                Rectangle {
                    anchors.fill: parent
                    radius: islandShape.radius - theme.islandBorderWidth
                    color: theme.bgInner
                }
                
                // Square off top corners to seamlessly connect to the black bezel above
                Rectangle {
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
        }
    }
    
    IslandComponents.IslandFillets {
        islandShape: islandShape
        radiusIsland: theme.radiusIsland
        bgBezel: theme.bgBezel
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
}
