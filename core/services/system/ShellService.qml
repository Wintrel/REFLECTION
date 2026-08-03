pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/reflection/.shell_settings.json"

    // 0: minimal, 1: contextual, 2: full idle width
    property int islandIdleMode: 1
    property bool islandMediaActivity: true
    property bool islandNotificationPreviews: true
    property real holdIndicatorIntensity: 1.0

    // 0: intelligent, 1: always visible, 2: edge reveal
    property bool taskbarEnabled: true
    property int taskbarVisibilityMode: 0
    property int taskbarHeight: 52
    property int taskbarIconSize: 28
    property bool workspaceNumbers: false

    property bool overviewEnabled: true
    property bool clipboardEnabled: true
    property bool ambientEnabled: true
    property bool wallpaperSelectorEnabled: true
    property bool loaded: false

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function setIslandIdleMode(value) { islandIdleMode = Math.round(clamp(value, 0, 2)); queueSave(); }
    function setIslandMediaActivity(value) { islandMediaActivity = value; queueSave(); }
    function setIslandNotificationPreviews(value) { islandNotificationPreviews = value; queueSave(); }
    function setHoldIndicatorIntensity(value) { holdIndicatorIntensity = clamp(value, 0, 1); queueSave(); }
    function setTaskbarEnabled(value) { taskbarEnabled = value; queueSave(); }
    function setTaskbarVisibilityMode(value) { taskbarVisibilityMode = Math.round(clamp(value, 0, 2)); queueSave(); }
    function setTaskbarHeight(value) { taskbarHeight = Math.round(clamp(value, 44, 68)); queueSave(); }
    function setTaskbarIconSize(value) { taskbarIconSize = Math.round(clamp(value, 22, 36)); queueSave(); }
    function setWorkspaceNumbers(value) { workspaceNumbers = value; queueSave(); }
    function setOverviewEnabled(value) { overviewEnabled = value; queueSave(); }
    function setClipboardEnabled(value) { clipboardEnabled = value; queueSave(); }
    function setAmbientEnabled(value) { ambientEnabled = value; queueSave(); }
    function setWallpaperSelectorEnabled(value) { wallpaperSelectorEnabled = value; queueSave(); }

    function reset() {
        islandIdleMode = 1;
        islandMediaActivity = true;
        islandNotificationPreviews = true;
        holdIndicatorIntensity = 1.0;
        taskbarEnabled = true;
        taskbarVisibilityMode = 0;
        taskbarHeight = 52;
        taskbarIconSize = 28;
        workspaceNumbers = false;
        overviewEnabled = true;
        clipboardEnabled = true;
        ambientEnabled = true;
        wallpaperSelectorEnabled = true;
        queueSave();
    }

    function queueSave() {
        if (loaded)
            saveDebounce.restart();
    }

    function serializedConfig() {
        return JSON.stringify({
            islandIdleMode: islandIdleMode,
            islandMediaActivity: islandMediaActivity,
            islandNotificationPreviews: islandNotificationPreviews,
            holdIndicatorIntensity: holdIndicatorIntensity,
            taskbarEnabled: taskbarEnabled,
            taskbarVisibilityMode: taskbarVisibilityMode,
            taskbarHeight: taskbarHeight,
            taskbarIconSize: taskbarIconSize,
            workspaceNumbers: workspaceNumbers,
            overviewEnabled: overviewEnabled,
            clipboardEnabled: clipboardEnabled,
            ambientEnabled: ambientEnabled,
            wallpaperSelectorEnabled: wallpaperSelectorEnabled
        });
    }

    Timer {
        id: saveDebounce
        interval: 220
        repeat: false
        onTriggered: saveProcess.write(root.serializedConfig())
    }

    Process {
        id: saveProcess
        property bool writeAgain: false
        property string nextContents: ""

        function write(contents) {
            nextContents = contents;
            if (running) {
                writeAgain = true;
                return;
            }
            command = ["python3", "-c",
                "import pathlib,sys; pathlib.Path(sys.argv[1]).write_text(sys.argv[2])",
                root.configPath, nextContents];
            running = true;
        }

        onExited: {
            if (writeAgain) {
                writeAgain = false;
                write(nextContents);
            }
        }
    }

    Process {
        command: ["python3", "-c",
            "import pathlib,sys; p=pathlib.Path(sys.argv[1]); print(p.read_text() if p.exists() else '{}')",
            root.configPath]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var cfg = JSON.parse(data.trim() || "{}");
                    if (cfg.islandIdleMode !== undefined) root.islandIdleMode = Math.round(root.clamp(cfg.islandIdleMode, 0, 2));
                    if (cfg.islandMediaActivity !== undefined) root.islandMediaActivity = !!cfg.islandMediaActivity;
                    if (cfg.islandNotificationPreviews !== undefined) root.islandNotificationPreviews = !!cfg.islandNotificationPreviews;
                    if (cfg.holdIndicatorIntensity !== undefined) root.holdIndicatorIntensity = root.clamp(cfg.holdIndicatorIntensity, 0, 1);
                    if (cfg.taskbarEnabled !== undefined) root.taskbarEnabled = !!cfg.taskbarEnabled;
                    if (cfg.taskbarVisibilityMode !== undefined) root.taskbarVisibilityMode = Math.round(root.clamp(cfg.taskbarVisibilityMode, 0, 2));
                    if (cfg.taskbarHeight !== undefined) root.taskbarHeight = Math.round(root.clamp(cfg.taskbarHeight, 44, 68));
                    if (cfg.taskbarIconSize !== undefined) root.taskbarIconSize = Math.round(root.clamp(cfg.taskbarIconSize, 22, 36));
                    if (cfg.workspaceNumbers !== undefined) root.workspaceNumbers = !!cfg.workspaceNumbers;
                    if (cfg.overviewEnabled !== undefined) root.overviewEnabled = !!cfg.overviewEnabled;
                    if (cfg.clipboardEnabled !== undefined) root.clipboardEnabled = !!cfg.clipboardEnabled;
                    if (cfg.ambientEnabled !== undefined) root.ambientEnabled = !!cfg.ambientEnabled;
                    if (cfg.wallpaperSelectorEnabled !== undefined) root.wallpaperSelectorEnabled = !!cfg.wallpaperSelectorEnabled;
                } catch (error) {
                    console.log("ShellService: could not load settings: " + error);
                }
                root.loaded = true;
            }
        }
        onExited: root.loaded = true
        running: true
    }
}
