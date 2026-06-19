import QtQuick
import Quickshell

// Transparent fullscreen overlay that catches outside-clicks to dismiss
// the active popup. This is the Hyprland-safe dismissal strategy used by
// end4/illogical-impulse — no activeFocus/hover sensitivity, just clicks.
PanelWindow {
    id: root
    
    // Visible whenever there is an active popup
    visible: PopupManager.currentPopup !== null
    
    // Cover the full screen
    anchors { top: true; bottom: true; left: true; right: true }
    
    // Don't push other windows around
    exclusionMode: ExclusionMode.Ignore
    
    // Must NOT steal keyboard focus — we only care about mouse clicks
    focusable: false
    
    // Fully transparent — invisible to the user
    color: "transparent"
    
    // A single tap anywhere on the scrim closes the active popup
    TapHandler {
        onTapped: PopupManager.closeAll()
    }
}
