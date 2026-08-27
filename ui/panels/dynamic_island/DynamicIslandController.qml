import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import "../../../core/state" as State
import "../../../core/services/system"
import "../../../core/services/media"

Item {
    id: controller
    
    // States
    property int islandState: State.IslandState.idle
    property int previousState: State.IslandState.idle
    property bool isLocked: false

    // OSD
    property int osdMode: 0
    property int osdPriority: 1
    property string osdIcon: ""
    property string osdText: ""
    property string osdColor: ""

    // Media
    property var mprisPlayer: CiderService.activePlayer
    
    // Notifications
    property var currentNotif: null
    signal notificationReceived(var notif)
    
    // Used by timers to restore state correctly based on hover
    property bool isHovered: false

    // Force instantiate singletons so they run in the background
    property var _vol: VolumeService
    property var _bri: BrightnessService
    property var _net: NetworkService
    property var _bt: BluetoothService
    property var _pac: PacmanWatcherService
    property var _priv: PrivacyService

    onIslandStateChanged: {
        console.log("Island state changed to:", islandState);
        // Keep global state synced
        var modalStates = [State.IslandState.clipboard, State.IslandState.ciderExpanded, State.IslandState.filePicker, State.IslandState.settingsHub, State.IslandState.polkitAuth, State.IslandState.actionProgress, State.IslandState.prompt, State.IslandState.osd, State.IslandState.notification];
        if (modalStates.indexOf(islandState) === -1) {
            if (State.GlobalStates.settingsOpen) State.GlobalStates.settingsOpen = false;
            if (State.GlobalStates.filePickerOpen) State.GlobalStates.closeFilePicker();
            if (State.GlobalStates.clipboardOpen) State.GlobalStates.clipboardOpen = false;
        }
    }

    function dismissNotification() {
        if (islandState === State.IslandState.notification) {
            notifTimer.stop();
            var persistentStates = [State.IslandState.expanded, State.IslandState.notificationHistory, State.IslandState.prompt, State.IslandState.actionProgress, State.IslandState.reflectionGrid, State.IslandState.battery, State.IslandState.polkitAuth, State.IslandState.settingsHub, State.IslandState.filePicker, State.IslandState.ciderExpanded];
            if (persistentStates.indexOf(previousState) !== -1) {
                islandState = previousState;
            } else {
                islandState = isHovered ? State.IslandState.hover : State.IslandState.idle;
            }
            previousState = State.IslandState.idle;
        }
    }

    Timer {
        id: notifTimer
        interval: BehaviorService.notificationTimeout
        onTriggered: dismissNotification()
    }
    
    function stopTimers() {
        if (islandState === State.IslandState.notification) notifTimer.stop();
        else if (islandState === State.IslandState.osd) osdTimer.stop();
    }
    
    function restartTimers() {
        if (islandState === State.IslandState.notification) notifTimer.restart();
        else if (islandState === State.IslandState.osd) osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: BehaviorService.osdTimeout
        onTriggered: {
            if (islandState === State.IslandState.osd) {
                var persistentStates = [State.IslandState.expanded, State.IslandState.notificationHistory, State.IslandState.prompt, State.IslandState.actionProgress, State.IslandState.reflectionGrid, State.IslandState.battery, State.IslandState.polkitAuth, State.IslandState.settingsHub, State.IslandState.filePicker, State.IslandState.ciderExpanded, State.IslandState.clipboard];
                if (persistentStates.indexOf(previousState) !== -1) {
                    islandState = previousState;
                } else {
                    islandState = isHovered ? State.IslandState.hover : State.IslandState.idle;
                }
                previousState = State.IslandState.idle;
            }
        }
    }

    Connections {
        target: OsdService
        function onOsdRequested(mode, priority, icon, text, color) {
            // Critical and actionable system warnings remain visible even when
            // routine volume/brightness feedback has been disabled.
            if (!BehaviorService.routineOsdEnabled && priority <= 1)
                return;

            controller.osdMode = mode;
            controller.osdPriority = priority;
            controller.osdIcon = icon;
            controller.osdText = text;
            controller.osdColor = color;
            
            var duration = BehaviorService.osdTimeout;
            if (priority === 2) duration = Math.max(4000, BehaviorService.osdTimeout);
            if (priority === 3) duration = Math.max(8000, BehaviorService.osdTimeout);
            osdTimer.interval = duration;
            
            if (controller.islandState !== State.IslandState.notification || priority >= 2) {
                if (priority === 1) {
                    var modalStates = [State.IslandState.prompt, State.IslandState.actionProgress, State.IslandState.reflectionGrid, State.IslandState.polkitAuth, State.IslandState.settingsHub, State.IslandState.filePicker, State.IslandState.ciderExpanded, State.IslandState.clipboard];
                    if (modalStates.indexOf(controller.islandState) !== -1) {
                        return;
                    }
                }

                if (controller.islandState !== State.IslandState.osd && controller.islandState !== State.IslandState.notification) {
                    controller.previousState = controller.islandState;
                }
                
                controller.islandState = State.IslandState.osd;
                osdTimer.restart();
            }
        }
    }

    Connections {
        target: State.ReflectionState
        function onIsOpenChanged() {
            if (State.ReflectionState.isOpen) {
                if (controller.islandState !== State.IslandState.reflectionGrid && controller.islandState !== State.IslandState.notification) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = State.IslandState.reflectionGrid;
            } else {
                if (controller.islandState === State.IslandState.reflectionGrid) {
                    controller.islandState = controller.previousState || State.IslandState.idle;
                }
            }
        }
    }
    
    Connections {
        target: PromptService
        function onPromptRequested() {
            if (controller.islandState !== State.IslandState.prompt && controller.islandState !== State.IslandState.notification) {
                controller.previousState = controller.islandState;
            }
            controller.islandState = State.IslandState.prompt;
        }
        function onCanceled() {
            if (controller.islandState === State.IslandState.prompt) {
                controller.islandState = controller.previousState || State.IslandState.idle;
                if (controller.islandState === State.IslandState.settingsHub) {
                    controller.previousState = State.IslandState.idle;
                }
            }
        }
        function onSubmitted(text) {
            if (controller.islandState === State.IslandState.prompt) {
                controller.islandState = controller.previousState || State.IslandState.idle;
                if (controller.islandState === State.IslandState.settingsHub) {
                    controller.previousState = State.IslandState.idle;
                }
            }
        }
    }

    Connections {
        target: ActionProgressService
        function onIsResolvingChanged() {
            if (ActionProgressService.isResolving && controller.islandState === State.IslandState.actionProgress) {
                actionSuccessTimer.restart();
            }
        }
    }

    Connections {
        target: PolkitAuthService
        function onPolkitRequestStarted() {
            if (controller.islandState !== State.IslandState.polkitAuth && controller.islandState !== State.IslandState.notification) {
                controller.previousState = controller.islandState;
            }
            controller.islandState = State.IslandState.polkitAuth;
        }
        function onPolkitRequestFinished() {
            if (controller.islandState === State.IslandState.polkitAuth) {
                controller.islandState = controller.previousState || State.IslandState.idle;
                if (controller.islandState === State.IslandState.settingsHub) {
                    controller.previousState = State.IslandState.idle;
                }
            }
        }
    }
    
    Connections {
        target: State.GlobalStates
        function onSettingsOpenChanged() {
            if (State.GlobalStates.settingsOpen) {
                if (controller.islandState !== State.IslandState.settingsHub && controller.islandState !== State.IslandState.notification) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = State.IslandState.settingsHub;
            } else {
                if (controller.islandState === State.IslandState.settingsHub) {
                    var targetState = controller.previousState;
                    if (targetState === State.IslandState.settingsHub) targetState = State.IslandState.idle;
                    controller.islandState = targetState || State.IslandState.idle;
                }
            }
        }
        function onFilePickerOpenChanged() {
            if (State.GlobalStates.filePickerOpen) {
                if (controller.islandState !== State.IslandState.filePicker && controller.islandState !== State.IslandState.notification) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = State.IslandState.filePicker;
            } else {
                if (controller.islandState === State.IslandState.filePicker) {
                    var targetState = controller.previousState;
                    if (targetState === State.IslandState.filePicker) targetState = State.IslandState.idle;
                    controller.islandState = targetState || State.IslandState.idle;
                }
            }
        }
        function onClipboardOpenChanged() {
            console.log("Clipboard open changed:", State.GlobalStates.clipboardOpen);
            if (State.GlobalStates.clipboardOpen) {
                if (controller.islandState !== State.IslandState.clipboard && controller.islandState !== State.IslandState.notification) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = State.IslandState.clipboard;
            } else {
                if (controller.islandState === State.IslandState.clipboard) {
                    var targetState = controller.previousState;
                    if (targetState === State.IslandState.clipboard) targetState = State.IslandState.idle;
                    controller.islandState = targetState || State.IslandState.idle;
                }
            }
        }
    }
    
    Timer {
        id: actionSuccessTimer
        interval: 2000
        onTriggered: {
            if (controller.islandState === State.IslandState.actionProgress) {
                controller.islandState = State.IslandState.idle;
            }
            ActionProgressService.reset();
        }
    }

    // MediaPlayer {
    //     id: popSound
    //     source: "file:///usr/share/sounds/freedesktop/stereo/message.oga"
    //     audioOutput: AudioOutput { volume: 0.5 }
    // }

    NotificationServer {
        id: notificationServer
        onNotification: function() {
            var n = arguments.length > 0 ? arguments[0] : null;
            if (!n) return;
            
            var app = (n.appName || "").toLowerCase();
            if (app === "cider") {
                return;
            }
            
            var notifCopy = {
                summary: n.summary !== undefined ? n.summary : "",
                body: n.body !== undefined ? n.body : "",
                appName: n.appName !== undefined ? n.appName : "",
                image: n.image !== undefined ? n.image : "",
                icon: n.icon !== undefined ? n.icon : "",
                invokeDefaultAction: function() { try { if (n) n.invokeDefaultAction(); } catch(e) {} },
                close: function() { try { if (n) n.close(); } catch(e) {} }
            };
            
            var notifData = {
                summary: notifCopy.summary,
                body: notifCopy.body,
                appName: notifCopy.appName,
                image: notifCopy.image,
                icon: notifCopy.icon
            };
            State.GlobalStates.notificationHistory.insert(0, notifData);
            
            controller.currentNotif = notifCopy;
            if (!BehaviorService.dndEnabled) {
                var modalStates = [State.IslandState.prompt, State.IslandState.actionProgress, State.IslandState.reflectionGrid, State.IslandState.polkitAuth, State.IslandState.settingsHub, State.IslandState.filePicker, State.IslandState.ciderExpanded];
                if (ShellService.islandNotificationPreviews && modalStates.indexOf(controller.islandState) === -1) {
                    if (controller.islandState !== State.IslandState.notification) {
                        controller.previousState = controller.islandState;
                    }
                    controller.islandState = State.IslandState.notification;
                    notifTimer.restart();
                }
                
                if (BehaviorService.notificationSoundEnabled)
                    popSound.play();
                
                State.GlobalStates.notificationTriggered();
                controller.notificationReceived(notifCopy);
            }
        }
    }
}
