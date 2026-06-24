pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    id: root

    // The name of the screen we want the UI on.
    // This binding re-evaluates automatically whenever Quickshell.screens changes.
    readonly property string targetScreenName: {
        var screens = Quickshell.screens;
        if (!screens || screens.length === 0) return "";

        // Prefer the first external monitor (name doesn't start with eDP)
        for (var i = 0; i < screens.length; ++i) {
            if (screens[i].name && !screens[i].name.startsWith("eDP") && screens[i].width > 640) {
                return screens[i].name;
            }
        }

        // Fallback to the first available screen (usually the internal laptop screen)
        return screens[0].name;
    }

    // Filtered array of Quickshell.screens containing only the anchor screen.
    // Used as the model for Variants blocks in panels — Variants will automatically
    // destroy and recreate PanelWindow instances when this changes.
    readonly property var anchorScreens: {
        var screens = Quickshell.screens;
        if (!screens || screens.length === 0) return [];

        var name = targetScreenName;
        var result = [];
        for (var i = 0; i < screens.length; ++i) {
            if (screens[i].name === name) {
                result.push(screens[i]);
                break;
            }
        }
        return result;
    }

    onTargetScreenNameChanged: {
        console.log("[MonitorService] Target screen changed to:", targetScreenName);
    }

    Component.onCompleted: {
        var screens = Quickshell.screens;
        console.log("[MonitorService] Initialized. Screen count:", screens ? screens.length : 0);
        for (var i = 0; i < screens.length; ++i) {
            console.log("[MonitorService]   screen[" + i + "]: " + screens[i].name + " (" + screens[i].width + "x" + screens[i].height + ")");
        }
        console.log("[MonitorService] Anchor:", targetScreenName);
    }
}
