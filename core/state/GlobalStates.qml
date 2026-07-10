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
    
    // Multi-monitor desktop geometry — computed once in the singleton so all
    // IdleVisualizer instances share the exact same values. This prevents
    // each PanelWindow from independently computing (and potentially getting
    // wrong) totalWidth due to QML binding timing.
    readonly property real globalDesktopMinX: {
        var mn = Infinity;
        var screens = Quickshell.screens;
        if (screens) {
            for (var i = 0; i < screens.length; i++) {
                if (screens[i] && screens[i].geometry) {
                    mn = Math.min(mn, screens[i].geometry.x);
                }
            }
        }
        return mn === Infinity ? 0 : mn;
    }
    
    readonly property real globalDesktopWidth: {
        var maxRight = 0;
        var screens = Quickshell.screens;
        if (screens) {
            for (var i = 0; i < screens.length; i++) {
                if (screens[i] && screens[i].geometry) {
                    var right = screens[i].geometry.x + screens[i].geometry.width;
                    maxRight = Math.max(maxRight, right);
                }
            }
        }
        var span = maxRight - root.globalDesktopMinX;
        return span > 0 ? span : 1920;
    }
    
    // Default to -0.5 (well off-screen) so there's no visible flash
    // if the property briefly returns to its non-animated value during loop reset
    property real globalSweepPos: -0.5
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