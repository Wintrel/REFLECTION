import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../../../core/state" as State
import "../../../../core/services/system"
import "../../../components" as Components

Item {
    id: root
    anchors.fill: parent
    property int islandState: 0
    property var theme: null

    // Only visible and active when in State 8 (Reflection)
    visible: opacity > 0
    layer.enabled: true
    opacity: islandState === 8 ? 1 : 0
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }

    // Ambient Void Background
    Components.Starfield {
        anchors.fill: parent
        starCount: 40
        starColor: root.theme ? root.theme.textMain : "#ffffff"
        opacity: 0.5 // Ethereal depth
    }

    property string query: State.ReflectionState.searchQuery
    property int currentIntent: 0 // 0 = App Search, 1 = Math Calculator, 2 = System Command

    // Math Parsing Logic
    function parseMath(input) {
        // Simple regex to check if it's a basic math equation
        if (/^[\d\s\+\-\*\/\.\(\)]+$/.test(input)) {
            try {
                // Remove spaces and eval safely
                var clean = input.replace(/\s+/g, "");
                // Prevent empty or purely formatting strings from evaluating
                if (clean.length > 0 && /[\+\-\*\/]/.test(clean) && !isNaN(clean[clean.length-1]) && !isNaN(clean[0])) {
                    var result = eval(clean);
                    if (result !== undefined && !isNaN(result)) {
                        return result.toString();
                    }
                }
            } catch(e) {}
        }
        return null;
    }

    // Shell command execution helper using the project's Process pattern
    function runCommand(cmd) {
        var p = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"] ; onExited: destroy() }',
            root
        );
        p.exited.connect(function() { p.destroy(); });
        p.running = true;
    }

    // Command definitions: each entry has aliases[], name, action, icon
    property var commandDefs: [
        // Power
        { aliases: ["sleep", "suspend"],                    name: "Sleep System",       action: "systemctl suspend",           icon: "bedtime" },
        { aliases: ["reboot", "restart"],                   name: "Reboot System",      action: "systemctl reboot",            icon: "restart_alt" },
        { aliases: ["shutdown", "poweroff", "power off"],   name: "Shutdown System",    action: "systemctl poweroff",          icon: "power_settings_new" },
        { aliases: ["lock", "lock screen"],                 name: "Lock Screen",        action: "loginctl lock-session",       icon: "lock" },
        { aliases: ["logout", "log out", "sign out"],       name: "Log Out",            action: "hyprctl dispatch exit & sleep 1 && pkill -9 -x quickshell",       icon: "logout" },
        { aliases: ["hibernate"],                            name: "Hibernate System",   action: "systemctl hibernate",         icon: "downloading" },

        // Utilities
        { aliases: ["screenshot", "snip", "capture"],       name: "Take Screenshot",    action: "sleep 0.3 && grim",           icon: "screenshot_monitor" },
        { aliases: ["screenrecord", "record", "recording"], name: "Screen Record",      action: "wf-recorder",                 icon: "videocam" },
        { aliases: ["clipboard", "paste history"],           name: "Clipboard History",  action: "cliphist list | wofi --dmenu | cliphist decode | wl-copy", icon: "content_paste" },
        { aliases: ["color", "colorpicker", "color picker", "pick color"], name: "Color Picker", action: "hyprpicker -a",   icon: "colorize" },

        // System controls
        { aliases: ["wifi on", "enable wifi"],               name: "Enable Wi-Fi",       action: "nmcli radio wifi on",         icon: "wifi" },
        { aliases: ["wifi off", "disable wifi"],             name: "Disable Wi-Fi",      action: "nmcli radio wifi off",        icon: "wifi_off" },
        { aliases: ["bluetooth on", "enable bluetooth", "bt on"],  name: "Enable Bluetooth",  action: "bluetoothctl power on",  icon: "bluetooth" },
        { aliases: ["bluetooth off", "disable bluetooth", "bt off"], name: "Disable Bluetooth", action: "bluetoothctl power off", icon: "bluetooth_disabled" },
        { aliases: ["dnd", "do not disturb", "silent"],      name: "Do Not Disturb",     action: "dunstctl set-paused true",    icon: "do_not_disturb_on" },
        { aliases: ["dnd off", "notifications on"],          name: "Notifications On",   action: "dunstctl set-paused false",   icon: "notifications_active" },

        // Performance
        { aliases: ["performance", "turbo", "boost"],       name: "Performance Mode",   action: "powerprofilesctl set performance", icon: "speed" },
        { aliases: ["balanced", "normal"],                   name: "Balanced Mode",      action: "powerprofilesctl set balanced",    icon: "tune" },
        { aliases: ["powersave", "battery saver", "quiet", "silent mode"], name: "Power Saver Mode", action: "powerprofilesctl set power-saver", icon: "battery_saver" },

        // File manager / terminal
        { aliases: ["files", "file manager", "nautilus"],    name: "Open File Manager",  action: "nautilus",                    icon: "folder_open" },
        { aliases: ["terminal", "term", "console"],          name: "Open Terminal",      action: "kitty",                       icon: "terminal" },
        { aliases: ["settings", "system settings"],          name: "System Settings",    action: "gnome-control-center",        icon: "settings" },

        // Display
        { aliases: ["night light", "nightlight", "blue light"], name: "Toggle Night Light", action: "pkill wlsunset || wlsunset -T 4500 -t 3500", icon: "nightlight" },

        // Customization
        { aliases: ["wallpaper", "wallpapers", "background"], name: "Wallpaper Selector", action: "quickshell ipc -c reflection call wallpaperSelector toggle", icon: "wallpaper" },

        // Ambient Modes
        { aliases: ["ambient active", "active ambient", "visualizer mode"], name: "Toggle Ambient Active", action: "quickshell ipc -c reflection call ambientActive activate", icon: "graphic_eq" },
        { aliases: ["ambient idle", "idle ambient", "shimmer mode"], name: "Toggle Ambient Idle", action: "quickshell ipc -c reflection call ambientIdle activate", icon: "lens_blur" },
    ]

    // Command Parsing Logic — supports aliases and prefix matching
    function parseCommand(input) {
        var lower = input.trim().toLowerCase();
        if (lower.length < 2) return null;

        // Exact alias match first
        for (var i = 0; i < commandDefs.length; i++) {
            var def = commandDefs[i];
            for (var j = 0; j < def.aliases.length; j++) {
                if (lower === def.aliases[j]) {
                    return { name: def.name, action: def.action, icon: def.icon };
                }
            }
        }

        // Prefix match (e.g. "shut" matches "shutdown")
        for (var k = 0; k < commandDefs.length; k++) {
            var def2 = commandDefs[k];
            for (var l = 0; l < def2.aliases.length; l++) {
                if (def2.aliases[l].indexOf(lower) === 0) {
                    return { name: def2.name, action: def2.action, icon: def2.icon };
                }
            }
        }

        return null;
    }

    property string mathResult: ""
    property var commandResult: null

    onQueryChanged: {
        var m = parseMath(query);
        if (m !== null) {
            mathResult = m;
            currentIntent = 1;
            return;
        }
        
        var c = parseCommand(query);
        if (c !== null) {
            commandResult = c;
            currentIntent = 2;
            return;
        }

        currentIntent = 0;
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // Search Input — Pill-shaped container with inline "Reflection" label
        Rectangle {
            id: searchContainer
            width: parent.width
            height: 44
            radius: 22
            color: root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.04) : "rgba(255,255,255,0.04)"
            border.width: searchInput.activeFocus ? 1 : 0
            border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.5) : "#ff9900"
            Behavior on border.width { NumberAnimation { duration: 200 } }
            
            // Materialization transition
            property bool isVisible: root.islandState === 8
            opacity: (root.islandState === 8) ? 1 : 0
            transform: Translate {
                y: (root.islandState === 8) ? 0 : 10
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                // "Reflection" text label
                Text {
                    text: "Reflection"
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                    color: searchInput.activeFocus ? (root.theme ? root.theme.accentPrimary : "#ff9900") : (root.theme ? root.theme.textSub : "#A6ADC8")
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                // Subtle separator dot
                Rectangle {
                    width: 3
                    height: 3
                    radius: 1.5
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.4) : "#66A6ADC8"
                }

                // Actual text input
                TextInput {
                    id: searchInput
                    width: parent.width - 100
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 15
                    font.weight: Font.Light // Ethereal weight
                    color: root.theme ? root.theme.textMain : "#FFFFFF"
                    selectionColor: root.theme ? root.theme.accentPrimary : "#ff9900"
                    selectedTextColor: "#000000"
                    clip: true
                    
                    text: State.ReflectionState.searchQuery
                    onTextChanged: State.ReflectionState.searchQuery = text

                    focus: islandState === 8
                    onVisibleChanged: {
                        if (visible && islandState === 8) {
                            forceActiveFocus();
                        }
                    }

                    Keys.onEscapePressed: {
                        State.ReflectionState.close();
                    }

                    Keys.onUpPressed: {
                        if (currentIntent === 0) appGrid.moveUp();
                    }
                    Keys.onDownPressed: {
                        if (currentIntent === 0) appGrid.moveDown();
                    }
                    Keys.onReturnPressed: {
                        if (currentIntent === 0) {
                            appGrid.launchSelected();
                        } else if (currentIntent === 1) {
                            // Copy math result to clipboard
                            runCommand("echo -n '" + root.mathResult + "' | wl-copy");
                            State.ReflectionState.close();
                        } else if (currentIntent === 2) {
                            if (commandResult) {
                                runCommand(commandResult.action);
                                State.ReflectionState.close();
                            }
                        }
                    }
                }
            }
            
            // Placeholder text
            Text {
                text: "What would you like to do?"
                anchors.left: parent.left
                anchors.leftMargin: 100 // After "Reflection" label + dot + spacing
                anchors.verticalCenter: parent.verticalCenter
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 15
                color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.5) : "#80A6ADC8"
                visible: searchInput.text.length === 0
            }
        }

        // View Stack based on Intent
        Item {
            id: viewStack
            width: parent.width
            height: parent.height - searchContainer.height - 14
            visible: State.ReflectionState.searchQuery.length > 0
            
            // Materialization transition
            property bool isVisible: root.islandState === 8 && State.ReflectionState.searchQuery.length > 0
            opacity: (root.islandState === 8 && State.ReflectionState.searchQuery.length > 0) ? 1 : 0
            transform: Translate {
                y: (root.islandState === 8 && State.ReflectionState.searchQuery.length > 0) ? 0 : 10
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            // INTENT 0: App Search & Orchestration
            ReflectionAppGrid {
                id: appGrid
                anchors.fill: parent
                theme: root.theme
                query: root.query
                visible: currentIntent === 0
            }

            // INTENT 1: Math Calculator — Contained card
            Item {
                anchors.fill: parent
                visible: currentIntent === 1
                
                Rectangle {
                    width: Math.min(320, parent.width * 0.85)
                    height: Math.min(110, parent.height * 0.7)
                    anchors.centerIn: parent
                    radius: 16
                    color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.08) : "rgba(255, 153, 0, 0.08)"
                    border.width: 1
                    border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.2) : "rgba(255, 153, 0, 0.2)"
                    
                    layer.enabled: true
                    layer.effect: Glow {
                        radius: 12
                        samples: 24
                        color: Qt.rgba(root.theme ? root.theme.accentPrimary.r : 1, root.theme ? root.theme.accentPrimary.g : 0.6, root.theme ? root.theme.accentPrimary.b : 0, 0.15)
                        transparentBorder: true
                    }
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        // Expression echo
                        Text {
                            text: root.query
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            color: root.theme ? root.theme.textSub : "#A6ADC8"
                        }
                        
                        // Result
                        Text {
                            text: "= " + root.mathResult
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: Math.min(40, root.parent ? 40 : 40)
                            font.weight: Font.Bold
                            color: root.theme ? root.theme.accentPrimary : "#ff9900"
                        }
                    }
                }
                
                Text {
                    text: "Press Enter to copy"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Math.max(4, parent.height * 0.03)
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.5) : "#80A6ADC8"
                    visible: parent.height > 80
                }
            }

            // INTENT 2: System Command — Orange accent card with icon
            Item {
                anchors.fill: parent
                visible: currentIntent === 2
                
                Rectangle {
                    id: cmdCard
                    width: Math.min(280, parent.width * 0.75)
                    height: Math.min(64, parent.height * 0.5)
                    anchors.centerIn: parent
                    radius: 16
                    color: cmdMouse.containsMouse
                        ? (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.15) : "rgba(255, 153, 0, 0.15)")
                        : (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.08) : "rgba(255, 153, 0, 0.08)")
                    border.width: 1
                    border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.3) : "rgba(255, 153, 0, 0.3)"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    layer.enabled: true
                    layer.effect: Glow {
                        radius: 12
                        samples: 24
                        color: Qt.rgba(root.theme ? root.theme.accentPrimary.r : 1, root.theme ? root.theme.accentPrimary.g : 0.6, root.theme ? root.theme.accentPrimary.b : 0, 0.15)
                        transparentBorder: true
                    }
                    
                    scale: cmdMouse.pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 12
                        
                        // Command icon
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.2) : "rgba(255, 153, 0, 0.2)"
                            
                            Text {
                                text: commandResult ? commandResult.icon : "terminal"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 18
                                color: root.theme ? root.theme.accentPrimary : "#ff9900"
                                anchors.centerIn: parent
                            }
                        }
                        
                        Text {
                            text: commandResult ? commandResult.name : ""
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: root.theme ? root.theme.textMain : "#FFFFFF"
                        }
                    }
                    
                    MouseArea {
                        id: cmdMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (commandResult) {
                                runCommand(commandResult.action);
                                State.ReflectionState.close();
                            }
                        }
                    }
                }
                
                Text {
                    text: "Press Enter to execute"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Math.max(4, parent.height * 0.03)
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.5) : "#80A6ADC8"
                    visible: parent.height > 80
                }
            }
        }
    }
}
