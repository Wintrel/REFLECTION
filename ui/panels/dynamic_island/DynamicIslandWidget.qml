import QtQuick
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
                if (islandWidget.isLocked || islandWidget.islandState === 11 || islandWidget.islandState === 12 || islandWidget.islandState === 8 || islandWidget.islandState === 10 || islandWidget.islandState === 6 || islandWidget.islandState === 7) return;
                if (islandWidget.islandState === 3) controller.stopTimers();
                else if (islandWidget.islandState === 5) controller.stopTimers();
                else if (islandWidget.islandState !== 2 && islandWidget.islandState !== 4 && islandWidget.islandState !== 9 && islandWidget.islandState !== 13) islandWidget.islandState = 1
            }
            onExited: {
                controller.isHovered = false;
                if (islandWidget.isLocked || islandWidget.islandState === 11 || islandWidget.islandState === 12 || islandWidget.islandState === 8 || islandWidget.islandState === 10 || islandWidget.islandState === 6 || islandWidget.islandState === 7) return;
                if (islandWidget.islandState === 3) controller.restartTimers();
                else if (islandWidget.islandState === 5) controller.restartTimers();
                else if (islandWidget.islandState !== 2 && islandWidget.islandState !== 4 && islandWidget.islandState !== 9 && islandWidget.islandState !== 13) islandWidget.islandState = 0
            }
            onClicked: {
                if (islandWidget.isLocked || islandWidget.islandState === 8 || islandWidget.islandState === 10 || islandWidget.islandState === 6 || islandWidget.islandState === 7) return;
                
                if (islandWidget.islandState === 12) {
                    State.GlobalStates.closeFilePicker();
                    return;
                }
                if (islandWidget.islandState === 11) {
                    State.GlobalStates.settingsOpen = false;
                    return;
                }
                if (islandWidget.islandState === 3) {
                    if (islandWidget.previousState === 2 || islandWidget.previousState === 4 || islandWidget.previousState === 9) {
                        islandWidget.islandState = islandWidget.previousState;
                    } else {
                        islandWidget.islandState = 1;
                    }
                    if (islandWidget.currentNotif) {
                        islandWidget.currentNotif.close();
                    }
                    islandWidget.previousState = 0;
                } else if (islandWidget.islandState === 4) {
                    islandWidget.islandState = 0;
                } else if (islandWidget.islandState === 2 || islandWidget.islandState === 9 || islandWidget.islandState === 13) {
                    islandWidget.islandState = containsMouse ? 1 : 0
                } else {
                    islandWidget.islandState = 2
                }
            }
        }
        
        // Center horizontally in the widget
        anchors.horizontalCenter: parent.horizontalCenter
        
        // Position negatively to hide the top rounded corners
        y: -theme.radiusIsland
        
        // Smooth sizing based on state
        width: {
            if (islandState === 8) {
                if (State.ReflectionState.searchQuery.length === 0) return theme.reflectionSearchW; // Search bar only
                if (reflectionContent.currentIntent === 0) return theme.reflectionGridW; // App Grid
                return theme.reflectionFocusW; // Math / Command Intents
            }
            if (islandState === 13) return theme.islandCiderW; // Cider Ultra Expanded
            if (islandState === 12) return theme.islandFilePickerW; // File Picker
            if (islandState === 11) return theme.islandSettingsW; // Settings Hub
            if (islandState === 10) return theme.islandMaxW; // Polkit Auth
            if (islandState === 7) return theme.islandProgressW; // Action Progress
            if (islandState === 6) return theme.islandMaxW; // Prompt
            if (islandState === 5) return theme.islandHoverW;
            if (islandState === 4) return theme.islandHistoryW;
            if (islandState === 3) return theme.islandNotifW;
            if (islandState === 9) return theme.islandBatteryW;
            if (islandState === 2) return theme.islandMaxW;
            if (islandState === 1) return theme.islandHoverW;
            
            var hasM = islandWidget.mprisPlayer && islandWidget.mprisPlayer.isPlaying;
            var hasN = State.GlobalStates.notificationHistory.count > 0;
            return (hasM || hasN) ? theme.islandMinW : 120;
        }
        height: {
            var targetH = theme.islandMinH;
            if (islandState === 8) {
                if (State.ReflectionState.searchQuery.length === 0) targetH = theme.reflectionSearchH; // Search bar only
                else if (reflectionContent.currentIntent === 0) targetH = theme.reflectionGridH; // App Grid
                else targetH = theme.reflectionFocusH; // Math / Command Intents
            }
            else if (islandState === 13) targetH = theme.islandCiderH; // Cider Ultra Expanded
            else if (islandState === 12) targetH = theme.islandFilePickerH; // File Picker
            else if (islandState === 11) targetH = theme.islandSettingsH; // Settings Hub
            else if (islandState === 10) targetH = theme.islandMaxH; // Polkit Auth
            else if (islandState === 7) targetH = theme.islandProgressH; // Action Progress
            else if (islandState === 6) targetH = theme.islandMaxH; // Prompt
            else if (islandState === 5) targetH = theme.islandHoverH;
            else if (islandState === 4) targetH = historyContent.computedHeight;
            else if (islandState === 3) targetH = theme.islandNotifH;
            else if (islandState === 9) targetH = theme.islandBatteryH;
            else if (islandState === 2) targetH = theme.islandMaxH;
            else if (islandState === 1) targetH = theme.islandHoverH;
            return targetH + theme.radiusIsland;
        }
        
        radius: theme.radiusIsland
        color: theme.bgBezel
        
        Behavior on width {
            NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo }
        }
        
        Behavior on height {
            NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo }
        }
        
        // The inner inset content area
        Rectangle {
            id: innerShape
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            anchors.bottomMargin: 4
            anchors.topMargin: theme.radiusIsland + 4
            
            radius: parent.radius - 2
            color: theme.bgInner
            clip: true
            
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
