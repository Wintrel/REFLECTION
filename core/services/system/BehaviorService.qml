pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/reflection/.behavior_settings.json"

    property int settingsHoldDuration: 450
    property bool holdFeedbackEnabled: true
    property bool dndEnabled: false
    property bool routineOsdEnabled: true
    property bool notificationSoundEnabled: true
    property int notificationTimeout: 5000
    property int osdTimeout: 2000
    property bool loaded: false

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function setSettingsHoldDuration(value) {
        root.settingsHoldDuration = Math.round(root.clamp(value, 250, 1000));
        root.queueSave();
    }

    function setHoldFeedbackEnabled(value) {
        root.holdFeedbackEnabled = value;
        root.queueSave();
    }

    function setDndEnabled(value) {
        root.dndEnabled = value;
        root.queueSave();
    }

    function setRoutineOsdEnabled(value) {
        root.routineOsdEnabled = value;
        root.queueSave();
    }

    function setNotificationSoundEnabled(value) {
        root.notificationSoundEnabled = value;
        root.queueSave();
    }

    function setNotificationTimeout(value) {
        root.notificationTimeout = Math.round(root.clamp(value, 2000, 12000));
        root.queueSave();
    }

    function setOsdTimeout(value) {
        root.osdTimeout = Math.round(root.clamp(value, 1000, 6000));
        root.queueSave();
    }

    function queueSave() {
        if (root.loaded)
            saveDebounce.restart();
    }

    function serializedConfig() {
        return JSON.stringify({
            settingsHoldDuration: root.settingsHoldDuration,
            holdFeedbackEnabled: root.holdFeedbackEnabled,
            dndEnabled: root.dndEnabled,
            routineOsdEnabled: root.routineOsdEnabled,
            notificationSoundEnabled: root.notificationSoundEnabled,
            notificationTimeout: root.notificationTimeout,
            osdTimeout: root.osdTimeout
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
        id: loadProcess
        command: ["python3", "-c",
            "import pathlib,sys; p=pathlib.Path(sys.argv[1]); print(p.read_text() if p.exists() else '{}')",
            root.configPath]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var cfg = JSON.parse(data.trim() || "{}");
                    if (cfg.settingsHoldDuration !== undefined)
                        root.settingsHoldDuration = Math.round(root.clamp(cfg.settingsHoldDuration, 250, 1000));
                    if (cfg.holdFeedbackEnabled !== undefined)
                        root.holdFeedbackEnabled = !!cfg.holdFeedbackEnabled;
                    if (cfg.dndEnabled !== undefined)
                        root.dndEnabled = !!cfg.dndEnabled;
                    if (cfg.routineOsdEnabled !== undefined)
                        root.routineOsdEnabled = !!cfg.routineOsdEnabled;
                    if (cfg.notificationSoundEnabled !== undefined)
                        root.notificationSoundEnabled = !!cfg.notificationSoundEnabled;
                    if (cfg.notificationTimeout !== undefined)
                        root.notificationTimeout = Math.round(root.clamp(cfg.notificationTimeout, 2000, 12000));
                    if (cfg.osdTimeout !== undefined)
                        root.osdTimeout = Math.round(root.clamp(cfg.osdTimeout, 1000, 6000));
                } catch (error) {
                    console.log("BehaviorService: could not load settings: " + error);
                }
                root.loaded = true;
            }
        }
        onExited: root.loaded = true
        running: true
    }
}
