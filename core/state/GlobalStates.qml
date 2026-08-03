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
    property bool settingsOpen: false
    property bool immersiveOpen: false

    // Immersive transition lifecycle. `immersiveOpen` remains the actual
    // layer-shell visibility switch, while the island owns the visual handoff.
    readonly property int immersiveClosed: 0
    readonly property int immersiveOpening: 1
    readonly property int immersiveOpened: 2
    readonly property int immersiveClosing: 3
    property int immersivePhase: immersiveClosed
    readonly property bool immersiveTransitioning: immersivePhase === immersiveOpening || immersivePhase === immersiveClosing

    // Super+I dual action: release before the threshold for quick settings,
    // or keep holding to enter the immersive settings surface.
    property int settingsHoldDuration: 450
    property bool settingsShortcutArmed: false
    property bool settingsHoldConsumed: false
    property real settingsHoldProgress: 0
    property bool screenLocked: false
    property bool clipboardOpen: false
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
    property bool islandInOverlay: false // Controls if island renders on WlrLayer.Overlay
    
    // Tracks the dynamic height of the island
    property real currentIslandHeight: 40

    function openImmersive() {
        if (root.immersivePhase !== root.immersiveClosed)
            return;
        root.immersivePhase = root.immersiveOpening;
    }

    function closeImmersive() {
        if (root.immersivePhase !== root.immersiveOpened)
            return;
        root.immersivePhase = root.immersiveClosing;
    }

    function toggleImmersive() {
        if (root.immersivePhase === root.immersiveClosed)
            root.openImmersive();
        else if (root.immersivePhase === root.immersiveOpened)
            root.closeImmersive();
    }
    
    property bool filePickerOpen: false
    property string filePickerTitle: "Select File"
    property string filePickerFilterMode: "all"
    property var filePickerCallback: null

    property alias notificationHistory: historyModel
    ListModel {
        id: historyModel
    }
    
    // Signal to trigger global edge lighting
    signal notificationTriggered()

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

    Timer {
        id: settingsHoldTimer
        interval: root.settingsHoldDuration
        repeat: false

        onTriggered: {
            if (!settingsShortcut.pressed || !root.settingsShortcutArmed)
                return;

            root.settingsHoldProgress = 1;
            root.settingsHoldConsumed = true;
            root.settingsOpen = false;

            if (root.immersivePhase === root.immersiveClosed)
                root.openImmersive();
        }
    }

    NumberAnimation {
        id: settingsHoldChargeAnimation
        target: root
        property: "settingsHoldProgress"
        from: 0
        to: 1
        duration: root.settingsHoldDuration
        easing.type: Easing.InOutQuad
    }

    NumberAnimation {
        id: settingsHoldReleaseAnimation
        target: root
        property: "settingsHoldProgress"
        to: 0
        duration: 110
        easing.type: Easing.OutCubic
    }

    GlobalShortcut {
        id: settingsShortcut
        name: "settingsHold"
        description: "Tap for quick settings, hold for immersive settings"

        onPressed: {
            settingsHoldTimer.stop();
            settingsHoldChargeAnimation.stop();
            settingsHoldReleaseAnimation.stop();
            root.settingsHoldProgress = 0;
            root.settingsShortcutArmed = !root.immersiveTransitioning;
            root.settingsHoldConsumed = false;

            if (root.settingsShortcutArmed) {
                settingsHoldTimer.restart();
                settingsHoldChargeAnimation.restart();
            }
        }

        onReleased: {
            if (!root.settingsShortcutArmed)
                return;

            root.settingsShortcutArmed = false;
            settingsHoldTimer.stop();
            settingsHoldChargeAnimation.stop();
            settingsHoldReleaseAnimation.from = root.settingsHoldProgress;
            settingsHoldReleaseAnimation.restart();

            if (root.settingsHoldConsumed) {
                root.settingsHoldConsumed = false;
                return;
            }

            if (root.immersivePhase === root.immersiveOpened)
                root.closeImmersive();
            else
                root.settingsOpen = !root.settingsOpen;
        }
    }

    GlobalShortcut {
        name: "overviewToggle"
        description: "Toggles overview on press"

        onPressed: {
            root.overviewOpen = !root.overviewOpen;
        }
    }
    
    GlobalShortcut {
        name: "islandOverlayToggle"
        description: "Toggles whether the dynamic island renders on top of fullscreen windows"

        onPressed: {
            root.islandInOverlay = !root.islandInOverlay;
        }
    }
    
    // Ambient States
    property bool ambientIdleActive: false
    property bool ambientActiveMode: false
    property bool anyAmbientActive: ambientIdleActive || ambientActiveMode
    
    onAnyAmbientActiveChanged: {
        var stateArg = root.anyAmbientActive ? "idle" : "wake";
        var scriptPath = Quickshell.env("HOME") + "/.config/quickshell/reflection/scripts/ambient_wallpaper.sh";
        var w = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "' + scriptPath + '", "' + stateArg + '"] ; onExited: destroy() }', root);
        w.exited.connect(function() { w.destroy(); });
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
            if (root.ambientActiveMode) return;
            root.ambientIdleActive = !root.ambientIdleActive;
        }
        function turnOn() {
            if (root.ambientActiveMode) return;
            root.ambientIdleActive = true;
        }
        function turnOff() {
            root.ambientIdleActive = false;
        }
    }
    
    IpcHandler {
        target: "ambientActive"
        function activate() {
            if (root.ambientIdleActive) root.ambientIdleActive = false;
            root.ambientActiveMode = !root.ambientActiveMode;
        }
        function turnOn() {
            if (root.ambientIdleActive) root.ambientIdleActive = false;
            root.ambientActiveMode = true;
        }
        function turnOff() {
            root.ambientActiveMode = false;
        }
    }
    
    IpcHandler {
        target: "wallpaperSelector"
        function toggle() {
            root.wallpaperSelectorOpen = !root.wallpaperSelectorOpen;
        }
    }
    
    IpcHandler {
        target: "settings"
        function toggle() {
            root.settingsOpen = !root.settingsOpen;
        }
    }

    IpcHandler {
        target: "immersive"
        function toggle() {
            root.toggleImmersive();
        }
        function open() {
            root.openImmersive();
        }
        function close() {
            root.closeImmersive();
        }
    }

    IpcHandler {
        target: "overview"
        function toggle() {
            root.overviewOpen = !root.overviewOpen;
        }
    }

    function openFilePicker(title, filterMode, callback) {
        root.filePickerTitle = title || "Select File";
        root.filePickerFilterMode = filterMode || "all";
        root.filePickerCallback = callback;
        if (root.filePickerOpen) root.filePickerOpen = false;
        root.filePickerOpen = true;
    }
    
    function closeFilePicker() {
        root.filePickerOpen = false;
    }
    
    IpcHandler {
        target: "clipboard"
        function toggle() {
            root.clipboardOpen = !root.clipboardOpen;
        }
    }
    
    IpcHandler {
        target: "controlCenter"
        function toggle() {
            root.controlCenterOpen = !root.controlCenterOpen;
        }
    }
}
