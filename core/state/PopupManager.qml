pragma Singleton
import QtQuick
import Quickshell

// PopupManager — coordinates mutually exclusive popups and provides a
// transparent fullscreen scrim that catches outside-clicks to dismiss them.
// This is the Hyprland-safe approach: no activeFocus tracking (which fires
// spuriously on hover due to focus-follows-mouse), just click detection.
QtObject {
    id: root
    
    signal popupOpened(var sender)
    
    // The currently visible popup window (set by registerPopup)
    property var currentPopup: null
    
    function registerPopup(sender) {
        root.currentPopup = sender
        root.popupOpened(sender)
    }
    
    function closeAll() {
        if (root.currentPopup && typeof root.currentPopup.hide === "function") {
            root.currentPopup.hide()
        }
        root.currentPopup = null
    }
    
    // Transparent fullscreen scrim — sits behind popups, catches outside clicks
    property var _scrim: PopupScrim {}
}

