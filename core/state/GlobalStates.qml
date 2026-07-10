import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool barOpen: true
    property bool crosshairOpen: false
    property bool sidebarLeftOpen: false
    property bool sidebarRightOpen: false
    property bool mediaControlsOpen: false
    property bool osdBrightnessOpen: false
    property bool osdVolumeOpen: false
    property bool oskOpen: false
    property bool overlayOpen: false
    property bool overviewOpen: false
    property bool regionSelectorOpen: false
    property bool searchOpen: false
    property bool screenLocked: false
    property bool controlCenterOpen: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
    property bool screenTranslatorOpen: false
    property bool sessionOpen: false
    property bool superDown: false
    property bool superReleaseMightTrigger: true
    property bool wallpaperSelectorOpen: false
    property bool workspaceShowNumbers: false
    property bool bottomPanelOpen: false
    property bool dndEnabled: false

    property alias notificationHistory: historyModel
    ListModel {
        id: historyModel
    }

    onSidebarRightOpenChanged: {
        if (GlobalStates.sidebarRightOpen) {
            Notifications.timeoutAll();
            Notifications.markAllRead();
        }
    }

    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            root.superDown = true
        }
        onReleased: {
            root.superDown = false
        }
    }
    
    // Ambient Idle State
    property bool ambientIdleActive: false
    
    onAmbientIdleActiveChanged: {
        var stateArg = root.ambientIdleActive ? "idle" : "wake";
        var scriptPath = Quickshell.env("HOME") + "/.config/quickshell/reflection/scripts/ambient_wallpaper.sh";
        var w = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "' + scriptPath + '", "' + stateArg + '"] }', root);
        w.running = true;
    }
    
    property real globalSweepPos: 0
    SequentialAnimation on globalSweepPos {
        loops: Animation.Infinite
        running: root.ambientIdleActive
        NumberAnimation { from: -0.2; to: 1.2; duration: 6000; easing.type: Easing.InOutSine }
        PauseAnimation { duration: 1500 }
    }
    
    IpcHandler {
        target: "ambientIdle"
        function activate() {
            root.ambientIdleActive = !root.ambientIdleActive;
        }
    }
}