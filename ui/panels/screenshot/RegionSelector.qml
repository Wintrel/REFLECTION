pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../../core/state" as State
import "../launcher" as Launcher

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        delegate: Loader {
            id: regionSelectorLoader
            required property var modelData
            active: ScreenshotState.isOpen

            sourceComponent: RegionSelection {
                screen: regionSelectorLoader.modelData
            }
        }
    }

    IpcHandler {
        target: "regionScreenshot"
        function trigger() {
            Launcher.AppLauncherState.close()
            State.GlobalStates.controlCenterOpen = false
            ScreenshotState.isOpen = true
        }
    }

    GlobalShortcut {
        name: "regionScreenshot"
        description: "Takes a screenshot of the selected region"
        onPressed: {
            Launcher.AppLauncherState.close()
            State.GlobalStates.controlCenterOpen = false
            ScreenshotState.isOpen = true
        }
    }
}
