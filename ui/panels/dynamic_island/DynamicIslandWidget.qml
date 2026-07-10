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
import "../../components" as Components
import "./components" as IslandComponents

Item {
    id: islandWidget
    
    Core.Theme { id: theme }

    // Dynamically bind the container size to exactly the visible bounding box of the island
    width: islandShape.width + (2 * theme.radiusIsland)
    height: islandShape.height - theme.radiusIsland
    
    // State machine for the island: 0 = Minimized, 1 = Hovered, 2 = Expanded, 3 = Notification, 4 = History, 5 = OSD
    property int islandState: 0
    property int previousState: 0
    
    // Privacy mode for Lockscreen
    property bool isLocked: false

    // OSD Properties
    property int osdMode: 0
    property int osdPriority: 1
    property string osdIcon: ""
    property string osdText: ""
    property string osdColor: ""
    
    // Force instantiate singletons so they run in the background
    property var _vol: VolumeService
    property var _bri: BrightnessService
    property var _net: NetworkService
    property var _bt: BluetoothService
    
    function dismissNotification() {
        if (islandWidget.islandState === 3) {
            notifTimer.stop();
            if (islandWidget.previousState === 2 || islandWidget.previousState === 4 || islandWidget.previousState === 9) {
                islandWidget.islandState = islandWidget.previousState;
            } else {
                islandWidget.islandState = islandShape.mouseArea.containsMouse ? 1 : 0;
            }
            islandWidget.previousState = 0;
        }
    }

    // Auto-dismiss timer for notifications
    Timer {
        id: notifTimer
        interval: 5000 // 5 seconds
        onTriggered: islandWidget.dismissNotification()
    }
    
    // Auto-dismiss timer for OSD
    Timer {
        id: osdTimer
        interval: 2000 // 2 seconds
        onTriggered: {
            if (islandWidget.islandState === 5) {
                if (islandWidget.previousState === 2 || islandWidget.previousState === 4 || islandWidget.previousState === 9) {
                    islandWidget.islandState = islandWidget.previousState;
                } else {
                    islandWidget.islandState = islandShape.mouseArea.containsMouse ? 1 : 0;
                }
                islandWidget.previousState = 0;
            }
        }
    }
    
    Connections {
        target: OsdService
        function onOsdRequested(mode, priority, icon, text, color) {
            islandWidget.osdMode = mode;
            islandWidget.osdPriority = priority;
            islandWidget.osdIcon = icon;
            islandWidget.osdText = text;
            islandWidget.osdColor = color;
            
            var duration = 2000;
            if (priority === 2) duration = 4000;
            if (priority === 3) duration = 8000;
            osdTimer.interval = duration;
            
            if (islandWidget.islandState !== 5 && islandWidget.islandState !== 3) {
                islandWidget.previousState = islandWidget.islandState;
            }
            
            // Only interrupt notifications for Tier 2 and Tier 3 events
            if (islandWidget.islandState !== 3 || priority >= 2) {
                islandWidget.islandState = 5;
                osdTimer.restart();
            }
        }
    }

    Connections {
        target: State.ReflectionState
        function onIsOpenChanged() {
            if (State.ReflectionState.isOpen) {
                if (islandWidget.islandState !== 8 && islandWidget.islandState !== 3) {
                    islandWidget.previousState = islandWidget.islandState;
                }
                islandWidget.islandState = 8;
            } else {
                if (islandWidget.islandState === 8) {
                    islandWidget.islandState = islandWidget.previousState || 0;
                }
            }
        }
    }
    
    Connections {
        target: PromptService
        function onPromptRequested() {
            if (islandWidget.islandState !== 6 && islandWidget.islandState !== 3) {
                islandWidget.previousState = islandWidget.islandState;
            }
            islandWidget.islandState = 6;
        }
        function onCanceled() {
            if (islandWidget.islandState === 6) {
                islandWidget.islandState = islandWidget.previousState || 0;
            }
        }
        function onSubmitted(text) {
            if (islandWidget.islandState === 6) {
                islandWidget.islandState = islandWidget.previousState || 0;
            }
        }
    }

    Connections {
        target: ActionProgressService
        function onActionRequested() {
            actionSuccessTimer.stop();
            if (islandWidget.islandState !== 7 && islandWidget.islandState !== 6 && islandWidget.islandState !== 3) {
                islandWidget.previousState = islandWidget.islandState;
            }
            islandWidget.islandState = 7;
        }
    }
    
    // Auto-dismiss timer for Action Progress success state
    Timer {
        id: actionSuccessTimer
        interval: 2000
        onTriggered: {
            if (islandWidget.islandState === 7) {
                // Always close the UI completely when an action fully completes.
                // Using previousState here is risky because it might be a transient state like 6 or 7.
                islandWidget.islandState = 0;
            }
            ActionProgressService.reset();
        }
    }
    
    Connections {
        target: ActionProgressService
        function onIsResolvingChanged() {
            if (ActionProgressService.isResolving) {
                actionSuccessTimer.restart();
            }
        }
    }

    // Play sound when a new notification arrives
    MediaPlayer {
        id: popSound
        source: "file:///usr/share/sounds/freedesktop/stereo/message.oga"
        audioOutput: AudioOutput { volume: 0.5 }
    }

    // Track the latest notification
    property var currentNotif: null
    
    NotificationServer {
        id: notificationServer
        onNotification: function() {
            var n = arguments.length > 0 ? arguments[0] : null;
            if (!n) return;
            
            // Ignore Cider's internal track-change notifications
            var app = (n.appName || "").toLowerCase();
            if (app === "cider") {
                return;
            }
            
            // Create a pure JS copy of the notification data
            var notifCopy = {
                summary: n.summary !== undefined ? n.summary : "",
                body: n.body !== undefined ? n.body : "",
                appName: n.appName !== undefined ? n.appName : "",
                image: n.image !== undefined ? n.image : "",
                icon: n.icon !== undefined ? n.icon : "",
                invokeDefaultAction: function() {
                    try { if (n) n.invokeDefaultAction(); } catch(e) {}
                },
                close: function() {
                    try { if (n) n.close(); } catch(e) {}
                }
            };
            
            // Store in Global History
            var notifData = {
                summary: notifCopy.summary,
                body: notifCopy.body,
                appName: notifCopy.appName,
                image: notifCopy.image,
                icon: notifCopy.icon
            };
            State.GlobalStates.notificationHistory.insert(0, notifData);
            
            islandWidget.currentNotif = notifCopy;
            if (islandWidget.islandState !== 3) {
                islandWidget.previousState = islandWidget.islandState;
            }
            islandWidget.islandState = 3;
            notifTimer.restart();
            popSound.play();
        }
    }
    
    // MPRIS Player Tracking
    property int currentPlayerIndex: 0
    property var mprisPlayer: null
    
    function cyclePlayer() {
        if (playerInst) {
            playerInst.cyclePlayer();
        }
    }
    
    Instantiator {
        id: playerInst
        model: Mpris.players
        
        delegate: Item {
            visible: false
            property var playerItem: modelData
            
            // Re-evaluate whenever playback state changes
            Connections {
                target: playerItem
                function onIsPlayingChanged() { playerInst.updatePlayer(); }
                function onLengthChanged() { playerInst.updatePlayer(); }
            }
            
            // Auto-pause media when entering Ambient Idle
            Connections {
                target: State.GlobalStates
                function onAmbientIdleActiveChanged() {
                    if (State.GlobalStates.ambientIdleActive && playerItem && playerItem.isPlaying) {
                        playerItem.pause();
                    }
                }
            }
        }
        
        function updatePlayer() {
            if (playerInst.count === 0) {
                islandWidget.mprisPlayer = null;
                return;
            }
            
            var bestPlayer = null;
            var bestScore = -1;
            
            for (var i = 0; i < playerInst.count; i++) {
                var p = playerInst.objectAt(i).playerItem;
                if (!p) continue;
                
                var score = 0;
                // Priority 1: Actively playing
                if (p.isPlaying) score = 10;
                
                // Priority 2: Has a track loaded (length > 0)
                if (p.length > 0) score += 2;
                
                // Bias towards currently selected player to prevent jitter
                if (islandWidget.mprisPlayer && islandWidget.mprisPlayer === p) {
                    score += 0.5;
                }
                
                if (score > bestScore) {
                    bestScore = score;
                    bestPlayer = p;
                    islandWidget.currentPlayerIndex = i;
                }
            }
            
            islandWidget.mprisPlayer = bestPlayer;
        }
        
        function cyclePlayer() {
            if (playerInst.count <= 1) return;
            islandWidget.currentPlayerIndex = (islandWidget.currentPlayerIndex + 1) % playerInst.count;
            islandWidget.mprisPlayer = playerInst.objectAt(islandWidget.currentPlayerIndex).playerItem;
        }
        
        onObjectAdded: updatePlayer()
        onObjectRemoved: updatePlayer()
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
                if (islandWidget.isLocked || islandWidget.islandState === 8 || islandWidget.islandState === 6 || islandWidget.islandState === 7) return;
                if (islandWidget.islandState === 3) notifTimer.stop();
                else if (islandWidget.islandState === 5) osdTimer.stop();
                else if (islandWidget.islandState !== 2 && islandWidget.islandState !== 4 && islandWidget.islandState !== 9) islandWidget.islandState = 1
            }
            onExited: {
                if (islandWidget.isLocked || islandWidget.islandState === 8 || islandWidget.islandState === 6 || islandWidget.islandState === 7) return;
                if (islandWidget.islandState === 3) notifTimer.restart();
                else if (islandWidget.islandState === 5) osdTimer.restart();
                else if (islandWidget.islandState !== 2 && islandWidget.islandState !== 4 && islandWidget.islandState !== 9) islandWidget.islandState = 0
            }
            onClicked: {
                if (islandWidget.isLocked || islandWidget.islandState === 8 || islandWidget.islandState === 6 || islandWidget.islandState === 7) return;
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
                } else if (islandWidget.islandState === 2 || islandWidget.islandState === 9) {
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
            if (islandState === 7) return theme.islandNotifW; // Same width as Prompt
            if (islandState === 6) return theme.islandNotifW; // Same width as Notif
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
            else if (islandState === 7) targetH = theme.islandNotifH; // Same height as Prompt
            else if (islandState === 6) targetH = theme.islandNotifH; // Same height as Notif
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
                islandNotifW: theme.islandNotifW
                islandNotifH: theme.islandNotifH
            }
            
            IslandComponents.ActionProgressContent {
                islandState: islandWidget.islandState
                theme: theme
            }

            IslandComponents.ReflectionContent {
                id: reflectionContent
                islandState: islandWidget.islandState
                theme: theme
            }

            IslandComponents.BatteryContent {
                islandState: islandWidget.islandState
                theme: theme
                islandBatteryW: theme.islandBatteryW
                islandBatteryH: theme.islandBatteryH
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
