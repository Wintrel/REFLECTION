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
        }
    ]

    function applyTheme(themeName) {
        if (themeName === "Custom") {
            // Placeholder for future custom theme loading
            root.currentTheme = "Custom";
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
            
            // Save selection
            var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
            p.command = ["sh", "-c", "echo '" + themeName + "' > ~/.config/quickshell/reflection/.current_theme"];
            p.exited.connect(function() { p.destroy(); });
            p.running = true;
        }
    }

    Process {
        command: ["sh", "-c", "cat ~/.config/quickshell/reflection/.current_theme 2>/dev/null || echo 'Ghostly Stardust'"]
        stdout: SplitParser {
            onRead: data => { 
                var saved = data.trim();
                if (saved !== "") {
                    root.applyTheme(saved);
                }
            }
        }
        running: true
    }
}
