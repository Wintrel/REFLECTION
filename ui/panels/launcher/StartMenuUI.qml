import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.ui.panels.launcher
import qs.ui.panels.launcher.components

Item {
    id: root
    property var theme
    
    implicitWidth: 800
    implicitHeight: 600

    // Main Container
    Rectangle {
        anchors.fill: parent
        
        // Match Control Center Styling
        radius: theme.taskbarRadius
        color: theme.bgBezel
        
        // Square off the bottom corners to fuse with taskbar
        Rectangle {
            height: theme.taskbarRadius
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: theme.bgBezel
        }

        // Inner inset area
        Rectangle {
            anchors.fill: parent
            anchors.margins: theme.taskbarBorderWidth
            radius: parent.radius - 2
            color: theme.bgInner
            
            // Square off bottom inner corners
            Rectangle {
                height: theme.taskbarRadius
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                color: theme.bgInner
            }

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 20

                SearchBar {
                    id: searchBar
                    width: parent.width
                    theme: root.theme
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.theme.colorNotification ? root.theme.colorNotification : "#710cee"
                    opacity: 0.3
                }

                AppGrid {
                    width: parent.width
                    height: parent.height - searchBar.height - 40
                    theme: root.theme
                }
            }
        }
    }

    // IPC Handler Hook
    IpcHandler {
        target: "searchToggle"
        function trigger() {
            AppLauncherState.toggle()
        }
    }

    // Global Wayland Shortcut Hook
    GlobalShortcut {
        name: "quickshell:searchToggleRelease"
        onPressed: {
            AppLauncherState.toggle()
        }
    }

    // Close on Escape
    Shortcut {
        sequence: "Esc"
        onActivated: AppLauncherState.close()
    }
}
