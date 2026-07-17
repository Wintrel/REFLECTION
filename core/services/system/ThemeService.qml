pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Active Colors
    property color bgBezel: "#000000"
    property color bgInner: "#000000"
    property color textMain: "#D4D4D8"
    property color textSub: "#82828C"
    property color colorNotification: '#3F3F4A'
    property color colorMusic: '#525266'
    property color accentWorkspace: '#1C1C24'
    property color accentPrimary: '#8C8C9E'
    property color colorSystemShimmer: '#C0C0D0'
    property color bgBase: '#000000'

    // Geometry & Motion
    property int radiusIsland: 12
    property int taskbarRadius: 16
    property int animDuration: 600

    property string currentTheme: "Ghostly Stardust"

    property var themes: [
        {
            name: "Ghostly Stardust",
            bgBezel: "#000000",
            bgInner: "#000000",
            textMain: "#D4D4D8",
            textSub: "#82828C",
            colorNotification: "#3F3F4A",
            colorMusic: "#525266",
            accentWorkspace: "#1C1C24",
            accentPrimary: "#8C8C9E",
            colorSystemShimmer: "#C0C0D0",
            bgBase: "#000000"
        },
        {
            name: "Neon Cyber",
            bgBezel: "#000000",
            bgInner: "#0A0A0F",
            textMain: "#E0F0F0",
            textSub: "#508080",
            colorNotification: "#1A2830",
            colorMusic: "#0A3030",
            accentWorkspace: "#1A2222",
            accentPrimary: "#00FFAA",
            colorSystemShimmer: "#00FFFF",
            bgBase: "#000000"
        },
        {
            name: "Crimson Velvet",
            bgBezel: "#000000",
            bgInner: "#0A0000",
            textMain: "#F0E0E0",
            textSub: "#805050",
            colorNotification: "#301A1A",
            colorMusic: "#400A0A",
            accentWorkspace: "#2A1A1A",
            accentPrimary: "#FF3366",
            colorSystemShimmer: "#FF88AA",
            bgBase: "#000000"
        },
        {
            name: "Midnight Ocean",
            bgBezel: "#000000",
            bgInner: "#050A10",
            textMain: "#D0E0F0",
            textSub: "#607080",
            colorNotification: "#1A2535",
            colorMusic: "#102A4A",
            accentWorkspace: "#151A25",
            accentPrimary: "#3399FF",
            colorSystemShimmer: "#88CCFF",
            bgBase: "#000000"
        },
        {
            name: "Custom",
            bgBezel: "#000000",
            bgInner: "#111111",
            textMain: "#FFFFFF",
            textSub: "#AAAAAA",
            colorNotification: "#222222",
            colorMusic: "#333333",
            accentWorkspace: "#1A1A1A",
            accentPrimary: "#FF00FF",
            colorSystemShimmer: "#DDDDDD",
            bgBase: "#000000"
        }
    ]

    function saveConfig() {
        var cfg = {
            theme: root.currentTheme,
            radiusIsland: root.radiusIsland,
            taskbarRadius: root.taskbarRadius,
            animDuration: root.animDuration,
            customColors: {
                bgBezel: root.bgBezel.toString(),
                bgInner: root.bgInner.toString(),
                textMain: root.textMain.toString(),
                textSub: root.textSub.toString(),
                colorNotification: root.colorNotification.toString(),
                colorMusic: root.colorMusic.toString(),
                accentWorkspace: root.accentWorkspace.toString(),
                accentPrimary: root.accentPrimary.toString(),
                colorSystemShimmer: root.colorSystemShimmer.toString(),
                bgBase: root.bgBase.toString()
            }
        };
        var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        var jsonStr = JSON.stringify(cfg).replace(/'/g, "'\\''");
        p.command = ["sh", "-c", "echo '" + jsonStr + "' > ~/.config/quickshell/reflection/.theme_settings.json"];
        p.exited.connect(function() { p.destroy(); });
        p.running = true;
    }

    function applyTheme(themeName) {
        if (themeName === "Custom") {
            root.currentTheme = "Custom";
            root.saveConfig();
            return;
        }

        var theme = null;
        for (var i = 0; i < themes.length; i++) {
            if (themes[i].name === themeName) {
                theme = themes[i];
                break;
            }
        }
        
        if (theme) {
            root.currentTheme = theme.name;
            root.bgBezel = theme.bgBezel;
            root.bgInner = theme.bgInner;
            root.textMain = theme.textMain;
            root.textSub = theme.textSub;
            root.colorNotification = theme.colorNotification;
            root.colorMusic = theme.colorMusic;
            root.accentWorkspace = theme.accentWorkspace;
            root.accentPrimary = theme.accentPrimary;
            root.colorSystemShimmer = theme.colorSystemShimmer;
            root.bgBase = theme.bgBase;
            
            root.saveConfig();
        }
    }

    function updateCustomColor(propertyName, hexColor) {
        if (root.currentTheme !== "Custom") {
            root.currentTheme = "Custom";
        }
        
        if (propertyName in root) {
            root[propertyName] = hexColor;
        }
        
        root.saveConfig();
    }

    function updateGeometry(radius, duration) {
        if (radius >= 0) {
            root.radiusIsland = radius;
            root.taskbarRadius = radius + 4;
        }
        if (duration >= 0) {
            root.animDuration = duration;
        }
        root.saveConfig();
    }

    Process {
        command: ["sh", "-c", "cat ~/.config/quickshell/reflection/.theme_settings.json 2>/dev/null || echo '{}'"]
        stdout: SplitParser {
            onRead: data => { 
                try {
                    var raw = data.trim();
                    if (raw !== "" && raw !== "{}") {
                        var cfg = JSON.parse(raw);
                        
                        if (cfg.radiusIsland !== undefined) root.radiusIsland = cfg.radiusIsland;
                        if (cfg.taskbarRadius !== undefined) root.taskbarRadius = cfg.taskbarRadius;
                        if (cfg.animDuration !== undefined) root.animDuration = cfg.animDuration;
                        
                        if (cfg.theme === "Custom" && cfg.customColors) {
                            root.currentTheme = "Custom";
                            root.bgBezel = cfg.customColors.bgBezel;
                            root.bgInner = cfg.customColors.bgInner;
                            root.textMain = cfg.customColors.textMain;
                            root.textSub = cfg.customColors.textSub;
                            root.colorNotification = cfg.customColors.colorNotification;
                            root.colorMusic = cfg.customColors.colorMusic;
                            root.accentWorkspace = cfg.customColors.accentWorkspace;
                            root.accentPrimary = cfg.customColors.accentPrimary;
                            root.colorSystemShimmer = cfg.customColors.colorSystemShimmer;
                            root.bgBase = cfg.customColors.bgBase;
                        } else if (cfg.theme !== undefined) {
                            root.applyTheme(cfg.theme);
                        }
                    } else {
                        var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "cat ~/.config/quickshell/reflection/.current_theme 2>/dev/null || echo \\"Ghostly Stardust\\""] }', root);
                        p.stdout = Qt.createQmlObject('import Quickshell.Io; SplitParser { onRead: data => { var s = data.trim(); if(s!=="") root.applyTheme(s); } }', p);
                        p.exited.connect(function() { p.destroy(); });
                        p.running = true;
                    }
                } catch(e) {
                    console.log("Error loading theme config: " + e);
                }
            }
        }
        running: true
    }
}
