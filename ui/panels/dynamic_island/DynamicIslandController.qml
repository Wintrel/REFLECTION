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
    property int islandState: 0
    property int previousState: 0
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
    
    // Used by timers to restore state correctly based on hover
    property bool isHovered: false

    // Force instantiate singletons so they run in the background
    property var _vol: VolumeService
    property var _bri: BrightnessService
    property var _net: NetworkService
    property var _bt: BluetoothService

    onIslandStateChanged: {
        // Keep global state synced
        if (islandState !== 12 && islandState !== 11 && islandState !== 10 && islandState !== 7 && islandState !== 6 && islandState !== 5 && islandState !== 3) {
            if (State.GlobalStates.settingsOpen) State.GlobalStates.settingsOpen = false;
            if (State.GlobalStates.filePickerOpen) State.GlobalStates.closeFilePicker();
        }
    }

    function dismissNotification() {
        if (islandState === 3) {
            notifTimer.stop();
            var persistentStates = [2, 4, 6, 7, 8, 9, 10, 11, 12, 13];
            if (persistentStates.indexOf(previousState) !== -1) {
                islandState = previousState;
            } else {
                islandState = isHovered ? 1 : 0;
            }
            previousState = 0;
        }
    }

    Timer {
        id: notifTimer
        interval: 5000 // 5 seconds
        onTriggered: dismissNotification()
    }
    
    function stopTimers() {
        if (islandState === 3) notifTimer.stop();
        else if (islandState === 5) osdTimer.stop();
    }
    
    function restartTimers() {
        if (islandState === 3) notifTimer.restart();
        else if (islandState === 5) osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 2000 // 2 seconds
        onTriggered: {
            if (islandState === 5) {
                var persistentStates = [2, 4, 6, 7, 8, 9, 10, 11, 12, 13];
                if (persistentStates.indexOf(previousState) !== -1) {
                    islandState = previousState;
                } else {
                    islandState = isHovered ? 1 : 0;
                }
                previousState = 0;
            }
        }
    }

    Connections {
        target: OsdService
        function onOsdRequested(mode, priority, icon, text, color) {
            controller.osdMode = mode;
            controller.osdPriority = priority;
            controller.osdIcon = icon;
            controller.osdText = text;
            controller.osdColor = color;
            
            var duration = 2000;
            if (priority === 2) duration = 4000;
            if (priority === 3) duration = 8000;
            osdTimer.interval = duration;
            
            if (controller.islandState !== 3 || priority >= 2) {
                if (priority === 1) {
                    var modalStates = [6, 7, 8, 10, 11, 12, 13];
                    if (modalStates.indexOf(controller.islandState) !== -1) {
                        return;
                    }
                }

                if (controller.islandState !== 5 && controller.islandState !== 3) {
                    controller.previousState = controller.islandState;
                }
                
                controller.islandState = 5;
                osdTimer.restart();
            }
        }
    }

    Connections {
        target: State.ReflectionState
        function onIsOpenChanged() {
            if (State.ReflectionState.isOpen) {
                if (controller.islandState !== 8 && controller.islandState !== 3) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = 8;
            } else {
                if (controller.islandState === 8) {
                    controller.islandState = controller.previousState || 0;
                }
            }
        }
    }
    
    Connections {
        target: PromptService
        function onPromptRequested() {
            if (controller.islandState !== 6 && controller.islandState !== 3) {
                controller.previousState = controller.islandState;
            }
            controller.islandState = 6;
        }
        function onCanceled() {
            if (controller.islandState === 6) {
                controller.islandState = controller.previousState || 0;
                if (controller.islandState === 11) {
                    controller.previousState = 0;
                }
            }
        }
        function onSubmitted(text) {
            if (controller.islandState === 6) {
                controller.islandState = controller.previousState || 0;
                if (controller.islandState === 11) {
                    controller.previousState = 0;
                }
            }
        }
    }

    Connections {
        target: ActionProgressService
        function onActionRequested() {
            actionSuccessTimer.stop();
            if (controller.islandState !== 7 && controller.islandState !== 6 && controller.islandState !== 3) {
                controller.previousState = controller.islandState;
            }
            controller.islandState = 7;
        }
        function onIsResolvingChanged() {
            if (ActionProgressService.isResolving) {
                actionSuccessTimer.restart();
            }
        }
    }

    Connections {
        target: PolkitAuthService
        function onPolkitRequestStarted() {
            if (controller.islandState !== 10 && controller.islandState !== 3) {
                controller.previousState = controller.islandState;
            }
            controller.islandState = 10;
        }
        function onPolkitRequestFinished() {
            if (controller.islandState === 10) {
                controller.islandState = controller.previousState || 0;
                if (controller.islandState === 11) {
                    controller.previousState = 0;
                }
            }
        }
    }
    
    Connections {
        target: State.GlobalStates
        function onSettingsOpenChanged() {
            if (State.GlobalStates.settingsOpen) {
                if (controller.islandState !== 11 && controller.islandState !== 3) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = 11;
            } else {
                if (controller.islandState === 11) {
                    var targetState = controller.previousState;
                    if (targetState === 11) targetState = 0;
                    controller.islandState = targetState || 0;
                }
            }
        }
        function onFilePickerOpenChanged() {
            if (State.GlobalStates.filePickerOpen) {
                if (controller.islandState !== 12 && controller.islandState !== 3) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = 12;
            } else {
                if (controller.islandState === 12) {
                    var targetState = controller.previousState;
                    if (targetState === 12) targetState = 0;
                    controller.islandState = targetState || 0;
                }
            }
        }
    }
    
    Timer {
        id: actionSuccessTimer
        interval: 2000
        onTriggered: {
            if (controller.islandState === 7) {
                controller.islandState = 0;
            }
            ActionProgressService.reset();
        }
    }

    MediaPlayer {
        id: popSound
        source: "file:///usr/share/sounds/freedesktop/stereo/message.oga"
        audioOutput: AudioOutput { volume: 0.5 }
    }

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
            
            var modalStates = [6, 7, 8, 10, 11, 12, 13];
            if (modalStates.indexOf(controller.islandState) === -1) {
                if (controller.islandState !== 3) {
                    controller.previousState = controller.islandState;
                }
                controller.islandState = 3;
                notifTimer.restart();
            }
            
            popSound.play();
            
            State.GlobalStates.notificationTriggered();
        }
    }
}
