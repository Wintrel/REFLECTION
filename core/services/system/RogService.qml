pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/reflection/.rog_settings.json"
    readonly property string macroConfPath: Quickshell.env("HOME") + "/.config/hypr/custom/rog_macros.lua"
    readonly property string qsConfig: "reflection"

    // ── Hardware state ────────────────────────────────────────────────
    // 0: Quiet, 1: Balanced, 2: Performance
    property int performanceProfile: 1
    // 0: Integrated, 1: Hybrid, 2: AsusMuxDgpu
    property int gpuMode: 1
    // 0: 60%, 1: 80%, 2: 100%
    property int batteryLimit: 1
    // 0: off, 1: low, 2: med, 3: high
    property int ledBrightness: 1
    // Index into auraEffects list
    property int auraEffect: 0

    property bool loaded: false
    property bool _initialReadDone: false

    // ── Macro state ──────────────────────────────────────────────────

    readonly property var macroPresets: [
        { label: "Unmapped",           type: "none",    command: "" },
        { label: "Volume Down",        type: "command", command: "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-" },
        { label: "Volume Up",          type: "command", command: "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.0" },
        { label: "Mute Audio",         type: "command", command: "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
        { label: "Mute Microphone",    type: "command", command: "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
        { label: "Play / Pause",       type: "command", command: "playerctl play-pause" },
        { label: "Next Track",         type: "command", command: "playerctl next" },
        { label: "Previous Track",     type: "command", command: "playerctl previous" },
        { label: "Screenshot Region",  type: "command", command: "grimblast --notify copy area" },
        { label: "Screenshot Full",    type: "command", command: "grimblast --notify copy screen" },
        { label: "Toggle DND",         type: "ipc",     command: "quickshell ipc -c " + qsConfig + " call notifications toggleDnd" },
        { label: "Immersive Settings", type: "ipc",     command: "quickshell ipc -c " + qsConfig + " call immersive toggle" }
    ]

    // Keysyms for each macro slot — these are what Hyprland binds to
    readonly property var macroKeysyms: ["XF86AudioLowerVolume", "XF86AudioRaiseVolume", "XF86AudioMicMute", "XF86Launch4", "XF86Launch1"]

    // Macro mappings: array of 5 objects { presetIndex, label, command }
    property var macros: [
        { presetIndex: 1, label: "Volume Down",        command: "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-" },
        { presetIndex: 2, label: "Volume Up",          command: "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.0" },
        { presetIndex: 0, label: "Unmapped",           command: "" },
        { presetIndex: 0, label: "Unmapped",           command: "" },
        { presetIndex: 11, label: "Immersive Settings", command: "quickshell ipc -c " + qsConfig + " call immersive toggle" }
    ]

    readonly property var macroNames: ["M1", "M2", "M3", "M4", "M5 (ROG)"]

    // ── Lookup maps ──────────────────────────────────────────────────

    readonly property var profileNames: ["Quiet", "Balanced", "Performance"]
    readonly property var gpuModeNames: ["Integrated", "Hybrid", "AsusMuxDgpu"]
    readonly property var gpuModeLabels: ["Integrated", "Hybrid", "Discrete"]
    readonly property var batteryLimitValues: [60, 80, 100]
    readonly property var ledLevelNames: ["off", "low", "med", "high"]
    readonly property var auraEffectNames: ["static", "breathe", "rainbow-cycle", "strobe"]
    readonly property var auraEffectLabels: ["Static", "Breathe", "Rainbow", "Strobe"]

    // ── Public setters ───────────────────────────────────────────────

    function setPerformanceProfile(index) {
        var idx = Math.max(0, Math.min(2, Math.round(index)));
        performanceProfile = idx;
        profileSetProcess.command = ["asusctl", "profile", "set", profileNames[idx]];
        profileSetProcess.running = true;
    }

    function setGpuMode(index) {
        var idx = Math.max(0, Math.min(2, Math.round(index)));
        gpuMode = idx;
        gpuSetProcess.command = ["supergfxctl", "-m", gpuModeNames[idx]];
        gpuSetProcess.running = true;
    }

    function setBatteryLimit(index) {
        var idx = Math.max(0, Math.min(2, Math.round(index)));
        batteryLimit = idx;
        batterySetProcess.command = ["asusctl", "battery", "limit", String(batteryLimitValues[idx])];
        batterySetProcess.running = true;
    }

    function setLedBrightness(level) {
        var lvl = Math.max(0, Math.min(3, Math.round(level)));
        ledBrightness = lvl;
        ledSetProcess.command = ["asusctl", "leds", "set", ledLevelNames[lvl]];
        ledSetProcess.running = true;
    }

    function setAuraEffect(index) {
        var idx = Math.max(0, Math.min(auraEffectNames.length - 1, Math.round(index)));
        auraEffect = idx;
        auraSetProcess.command = ["asusctl", "aura", "effect", auraEffectNames[idx]];
        auraSetProcess.running = true;
        queueSave();
    }

    function setMacro(slotIndex, presetIndex) {
        if (slotIndex < 0 || slotIndex >= 5) return;
        if (presetIndex < 0 || presetIndex >= macroPresets.length) return;

        var preset = macroPresets[presetIndex];
        var updated = [];
        for (var i = 0; i < macros.length; i++) {
            if (i === slotIndex)
                updated.push({ presetIndex: presetIndex, label: preset.label, command: preset.command });
            else
                updated.push(macros[i]);
        }
        macros = updated;
        queueSave();
        generateMacroKeybinds();
    }

    // ── Persistence ──────────────────────────────────────────────────

    function queueSave() {
        if (loaded)
            saveDebounce.restart();
    }

    function serializedConfig() {
        return JSON.stringify({
            auraEffect: auraEffect,
            macros: macros
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

    // ── Load config from disk ────────────────────────────────────────

    Process {
        id: loadConfigProcess
        command: ["python3", "-c",
            "import pathlib,sys; p=pathlib.Path(sys.argv[1]); print(p.read_text() if p.exists() else '{}')",
            root.configPath]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var cfg = JSON.parse(data.trim() || "{}");
                    if (cfg.auraEffect !== undefined)
                        root.auraEffect = Math.max(0, Math.min(root.auraEffectNames.length - 1, cfg.auraEffect));
                    if (cfg.macros !== undefined && Array.isArray(cfg.macros) && cfg.macros.length === 5) {
                        var loadedMacros = [];
                        for (var i = 0; i < 5; i++) {
                            var m = cfg.macros[i];
                            loadedMacros.push({
                                presetIndex: m.presetIndex !== undefined ? m.presetIndex : 0,
                                label: m.label || "Unmapped",
                                command: m.command || ""
                            });
                        }
                        root.macros = loadedMacros;
                    }
                } catch (error) {
                    console.log("RogService: could not load config: " + error);
                }
                root.loaded = true;
            }
        }
        onExited: root.loaded = true
        running: true
    }

    // ── Read hardware state on startup ───────────────────────────────

    // Performance profile
    Process {
        id: profileGetProcess
        command: ["asusctl", "profile", "get"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                // "Active profile: Balanced"
                if (line.indexOf("Active profile:") >= 0) {
                    var name = line.split(":")[1].trim();
                    for (var i = 0; i < root.profileNames.length; i++) {
                        if (root.profileNames[i] === name) {
                            root.performanceProfile = i;
                            break;
                        }
                    }
                }
            }
        }
        running: true
    }

    // GPU mode
    Process {
        id: gpuGetProcess
        command: ["supergfxctl", "-g"]
        stdout: SplitParser {
            onRead: data => {
                var mode = data.trim();
                for (var i = 0; i < root.gpuModeNames.length; i++) {
                    if (root.gpuModeNames[i] === mode) {
                        root.gpuMode = i;
                        break;
                    }
                }
            }
        }
        running: true
    }

    // Battery limit
    Process {
        id: batteryGetProcess
        command: ["asusctl", "battery", "info"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                // "Current battery charge limit: 80%"
                var match = line.match(/(\d+)%/);
                if (match) {
                    var pct = parseInt(match[1]);
                    // Map to nearest option: 60, 80, 100
                    if (pct <= 70) root.batteryLimit = 0;
                    else if (pct <= 90) root.batteryLimit = 1;
                    else root.batteryLimit = 2;
                }
            }
        }
        running: true
    }

    // LED brightness
    Process {
        id: ledGetProcess
        command: ["asusctl", "leds", "get"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim().toLowerCase();
                // "Current keyboard led brightness: Low"
                if (line.indexOf("off") >= 0) root.ledBrightness = 0;
                else if (line.indexOf("low") >= 0) root.ledBrightness = 1;
                else if (line.indexOf("med") >= 0) root.ledBrightness = 2;
                else if (line.indexOf("high") >= 0) root.ledBrightness = 3;
            }
        }
        running: true
    }

    // ── Write processes ──────────────────────────────────────────────

    Process {
        id: profileSetProcess
        onExited: profileGetProcess.running = true
    }

    Process {
        id: gpuSetProcess
        onExited: gpuGetProcess.running = true
    }

    Process {
        id: batterySetProcess
        onExited: batteryGetProcess.running = true
    }

    Process {
        id: ledSetProcess
        onExited: ledGetProcess.running = true
    }

    Process {
        id: auraSetProcess
    }

    // ── Macro keybind generation ─────────────────────────────────────

    function generateMacroKeybinds() {
        var lines = [
            "-- Auto-generated by Reflection ROG settings",
            "-- Do not edit manually; changes will be overwritten.",
            "require(\"hyprland.lib\")",
            ""
        ];

        for (var i = 0; i < macros.length; i++) {
            var m = macros[i];
            var keysym = macroKeysyms[i];
            if (!m.command || m.command === "" || m.presetIndex === 0) {
                lines.push("-- " + macroNames[i] + ": unmapped");
                continue;
            }
            // Escape any single quotes in the command
            var escapedCmd = m.command.replace(/'/g, "'\\''");
            lines.push("hl.bind(\"" + keysym + "\", hl.dsp.exec_cmd('" + escapedCmd + "'), { description = \"ROG Macro: " + macroNames[i] + " — " + m.label + "\" })");
        }

        lines.push("");
        var content = lines.join("\n");

        macroWriteProcess.command = ["python3", "-c",
            "import pathlib,sys; pathlib.Path(sys.argv[1]).write_text(sys.argv[2])",
            macroConfPath, content];
        macroWriteProcess.running = true;
    }

    Process {
        id: macroWriteProcess
        onExited: {
            // Reload Hyprland to pick up new keybinds
            hyprReloadProcess.running = true;
        }
    }

    Process {
        id: hyprReloadProcess
        command: ["hyprctl", "reload"]
    }

    // Generate macro keybinds on first load
    Component.onCompleted: {
        // Delay to let config load first
        macroInitTimer.start();
    }

    Timer {
        id: macroInitTimer
        interval: 800
        repeat: false
        onTriggered: root.generateMacroKeybinds()
    }
}
