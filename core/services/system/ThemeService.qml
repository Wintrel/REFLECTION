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
    property color accentNotification: '#3F3F4A'
    property color accentMusic: '#525266'
    property color accentWorkspace: '#1C1C24'
    property color accentPrimary: '#8C8C9E'
    property color colorSystemShimmer: '#C0C0D0'
    property color bgBase: '#000000'
    property color surfaceCard: '#111115'
    property color surfaceOverlay: '#1A1A22'
    property color textMuted: '#50505A'
    property color accentSecondary: '#8C8C9E'
    property bool useGradients: false
    property color bgInnerGradientEnd: '#000000'
    property color surfaceCardGradientEnd: '#111115'
    property color accentPrimaryGradientEnd: '#8C8C9E'

    // Geometry & Motion
    property int radiusIsland: 12
    property int taskbarRadius: 16
    property int animDuration: 600
    
    // Effects
    property real edgeLightingIntensity: 0.6

    property string currentTheme: "Ghostly Stardust"

    property var themes: [
        {
            name: "Ghostly Stardust",
            bgBezel: "#000000",
            bgInner: "#000000",
            textMain: "#D4D4D8",
            textSub: "#82828C",
            accentNotification: "#3F3F4A",
            accentMusic: "#525266",
            accentWorkspace: "#1C1C24",
            accentPrimary: '#63636b',
            colorSystemShimmer: "#C0C0D0",
            bgBase: "#000000",
            surfaceCard: "#111115",
            surfaceOverlay: "#1A1A22",
            textMuted: "#50505A",
            accentSecondary: "#8C8C9E",
            useGradients: false,
            bgInnerGradientEnd: "#000000",
            surfaceCardGradientEnd: "#0A0A0D",
            accentPrimaryGradientEnd: "#727282"
        },
        {
            name: "Neon Cyber",
            bgBezel: "#05050A",
            bgInner: "#0A0A0F",
            textMain: "#E0F0F0",
            textSub: "#508080",
            accentNotification: "#1A2830",
            accentMusic: "#0A3030",
            accentWorkspace: "#1A2222",
            accentPrimary: "#00FFAA",
            colorSystemShimmer: "#00FFFF",
            bgBase: "#000000",
            surfaceCard: "#10161A",
            surfaceOverlay: "#152026",
            textMuted: "#304040",
            accentSecondary: "#00AAAA",
            useGradients: true,
            bgInnerGradientEnd: "#050A0F",
            surfaceCardGradientEnd: "#0A1015",
            accentPrimaryGradientEnd: "#00FFCC"
        },
        {
            name: "Crimson Velvet",
            bgBezel: "#050000",
            bgInner: "#0A0000",
            textMain: "#F0E0E0",
            textSub: "#805050",
            accentNotification: "#301A1A",
            accentMusic: "#400A0A",
            accentWorkspace: "#2A1A1A",
            accentPrimary: "#FF3366",
            colorSystemShimmer: "#FF88AA",
            bgBase: "#000000",
            surfaceCard: "#150505",
            surfaceOverlay: "#200A0A",
            textMuted: "#503030",
            accentSecondary: "#AA2244",
            useGradients: false,
            bgInnerGradientEnd: "#050000",
            surfaceCardGradientEnd: "#100000",
            accentPrimaryGradientEnd: "#CC2244"
        },
        {
            name: "Midnight Winter",
            bgBezel: "#06090f",
            bgInner: "#0b101a",
            textMain: "#E2E8F0",
            textSub: "#94A3B8",
            accentNotification: "#1E293B",
            accentMusic: "#334155",
            accentWorkspace: "#1E293B",
            accentPrimary: "#A5B4FC",
            colorSystemShimmer: "#E0E7FF",
            bgBase: "#000000",
            surfaceCard: "#121825",
            surfaceOverlay: "#1a2233",
            textMuted: "#475569",
            accentSecondary: '#2d347a',
            useGradients: true,
            bgInnerGradientEnd: "#000000",
            surfaceCardGradientEnd: "#06090f",
            accentPrimaryGradientEnd: '#3645ce'
        },
        {
            name: "Midnight Winter - Aurora",
            bgBezel: "#050B14",
            bgInner: "#0D1B2A",
            textMain: "#F1F5F9",
            textSub: "#94A3B8",
            accentNotification: "#111C2E",
            accentMusic: "#1B2A41",
            accentWorkspace: "#111C2E",
            accentPrimary: "#2DD4BF",
            colorSystemShimmer: "#CCFBF1",
            bgBase: "#020813",
            surfaceCard: "#15253A",
            surfaceOverlay: "#1E324A",
            textMuted: "#475569",
            accentSecondary: "#581C87",
            useGradients: true,
            bgInnerGradientEnd: "#050B14",
            surfaceCardGradientEnd: "#0D1B2A",
            accentPrimaryGradientEnd: "#818CF8"
        },
        {
            name: "Pure Midnight - Obsidian Violet",
            bgBezel: "#010204",
            bgInner: "#06070C",
            textMain: "#F8FAFC",
            textSub: "#94A3B8",
            accentNotification: "#0F111A",
            accentMusic: "#181B26",
            accentWorkspace: "#0F111A",
            accentPrimary: "#818CF8",
            colorSystemShimmer: "#E0E7FF",
            bgBase: "#000000",
            surfaceCard: "#0D0F18",
            surfaceOverlay: "#151824",
            textMuted: "#475569",
            accentSecondary: "#3730A3",
            useGradients: true,
            bgInnerGradientEnd: "#121422",
            surfaceCardGradientEnd: "#05060A",
            accentPrimaryGradientEnd: "#C084FC"
        },
        {
            name: "Custom",
            bgBezel: "#000000",
            bgInner: "#111111",
            textMain: "#FFFFFF",
            textSub: "#AAAAAA",
            accentNotification: "#222222",
            accentMusic: "#333333",
            accentWorkspace: "#1A1A1A",
            accentPrimary: "#FF00FF",
            colorSystemShimmer: "#DDDDDD",
            bgBase: "#000000",
            surfaceCard: "#1A1A1A",
            surfaceOverlay: "#252525",
            textMuted: "#666666",
            accentSecondary: "#AA00AA",
            useGradients: false,
            bgInnerGradientEnd: "#0A0A0A",
            surfaceCardGradientEnd: "#151515",
            accentPrimaryGradientEnd: "#880088"
        }
    ]

    function saveConfig() {
        var cfg = {
            theme: root.currentTheme,
            radiusIsland: root.radiusIsland,
            taskbarRadius: root.taskbarRadius,
            animDuration: root.animDuration,
            edgeLightingIntensity: root.edgeLightingIntensity,
            customColors: {
                bgBezel: root.bgBezel.toString(),
                bgInner: root.bgInner.toString(),
                textMain: root.textMain.toString(),
                textSub: root.textSub.toString(),
                accentNotification: root.accentNotification.toString(),
                accentMusic: root.accentMusic.toString(),
                accentWorkspace: root.accentWorkspace.toString(),
                accentPrimary: root.accentPrimary.toString(),
                colorSystemShimmer: root.colorSystemShimmer.toString(),
                bgBase: root.bgBase.toString(),
                surfaceCard: root.surfaceCard.toString(),
                surfaceOverlay: root.surfaceOverlay.toString(),
                textMuted: root.textMuted.toString(),
                accentSecondary: root.accentSecondary.toString(),
                useGradients: root.useGradients,
                bgInnerGradientEnd: root.bgInnerGradientEnd.toString(),
                surfaceCardGradientEnd: root.surfaceCardGradientEnd.toString(),
                accentPrimaryGradientEnd: root.accentPrimaryGradientEnd.toString(),
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
            root.accentNotification = theme.accentNotification;
            root.accentMusic = theme.accentMusic;
            root.accentWorkspace = theme.accentWorkspace;
            root.accentPrimary = theme.accentPrimary;
            root.colorSystemShimmer = theme.colorSystemShimmer;
            root.bgBase = theme.bgBase;
            root.surfaceCard = theme.surfaceCard;
            root.surfaceOverlay = theme.surfaceOverlay;
            root.textMuted = theme.textMuted;
            root.accentSecondary = theme.accentSecondary;
            root.useGradients = theme.useGradients !== undefined ? theme.useGradients : false;
            root.bgInnerGradientEnd = theme.bgInnerGradientEnd || root.bgInner;
            root.surfaceCardGradientEnd = theme.surfaceCardGradientEnd || root.surfaceCard;
            root.accentPrimaryGradientEnd = theme.accentPrimaryGradientEnd || root.accentPrimary;
            
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

    function setUseGradients(val) {
        if (root.useGradients === val) return;
        root.useGradients = val;
        
        if (currentTheme !== "Custom") {
            currentTheme = "Custom";
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

    function updateEdgeLighting(intensity) {
        if (intensity >= 0.0 && intensity <= 1.0) {
            root.edgeLightingIntensity = intensity;
            root.saveConfig();
        }
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
                        if (cfg.edgeLightingIntensity !== undefined) root.edgeLightingIntensity = cfg.edgeLightingIntensity;
                        
                        if (cfg.theme === "Custom" && cfg.customColors) {
                            root.currentTheme = "Custom";
                            root.bgBezel = cfg.customColors.bgBezel;
                            root.bgInner = cfg.customColors.bgInner;
                            root.textMain = cfg.customColors.textMain;
                            root.textSub = cfg.customColors.textSub;
                            root.accentNotification = cfg.customColors.accentNotification;
                            root.accentMusic = cfg.customColors.accentMusic;
                            root.accentWorkspace = cfg.customColors.accentWorkspace;
                            root.accentPrimary = cfg.customColors.accentPrimary;
                            root.colorSystemShimmer = cfg.customColors.colorSystemShimmer;
                            root.bgBase = cfg.customColors.bgBase;
                            root.surfaceCard = cfg.customColors.surfaceCard || root.surfaceCard;
                            root.surfaceOverlay = cfg.customColors.surfaceOverlay || root.surfaceOverlay;
                            root.textMuted = cfg.customColors.textMuted || root.textMuted;
                            root.accentSecondary = cfg.customColors.accentSecondary || root.accentSecondary;
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
