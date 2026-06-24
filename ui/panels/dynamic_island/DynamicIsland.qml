import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../core" as Core
import "../../../core/monitors"

// Scope container — Variants manages the PanelWindow lifecycle on monitor changes.
// When the anchor screen disappears (unplug), the PanelWindow is destroyed.
// When a new anchor screen appears (replug/fallback), a fresh PanelWindow is created.
Scope {
    Variants {
        model: MonitorService.anchorScreens

        delegate: PanelWindow {
            Core.Theme { id: theme }
            id: islandWindow

            required property var modelData
            screen: modelData

            WlrLayershell.keyboardFocus: (widget.islandState === 6 || widget.islandState === 8) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            
            // Anchor only to the top, so it centers horizontally by default
            anchors {
                top: true
            }
            
            // Make sure the window acts as an overlay and doesn't take up literal screen space
            exclusiveZone: 0
            
            // Transparent background for the panel itself
            color: "transparent"
            
            // Lock the Wayland surface size to the maximum possible bounds to prevent resizing wobble
            implicitWidth: Math.max(theme.islandMaxW, theme.islandHistoryW || 0, theme.reflectionGridW || 800) + (2 * theme.radiusIsland)
            implicitHeight: Math.max(theme.islandMaxH, theme.islandHistoryH || 0, theme.reflectionGridH || 600) + theme.radiusIsland
            
            // Mask the input/visual region exactly to the opaque pixels of the container
            // This perfectly prevents the window from blocking clicks on the desktop!
            mask: Region {
                item: widget
            }
            
            DynamicIslandWidget {
                id: widget
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
