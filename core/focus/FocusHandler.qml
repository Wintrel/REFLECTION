import QtQuick
import Quickshell

// FocusHandler — lightweight helper that tracks whether its targetWindow is
// "active" (visible) and emits focusLost when it closes.
//
// Dismissal is handled by PopupManager's scrim overlay (a transparent
// fullscreen PanelWindow that catches outside clicks). We do NOT use
// activeFocus/onActiveFocusChanged because Hyprland's focus-follows-mouse
// fires those on every hover, causing panels to close immediately.
Item {
    id: root
    
    // The PanelWindow this handler is attached to
    property var targetWindow
    
    // True while the panel is open
    property bool isActive: false
    
    signal focusLost()
    
    // Track visibility — when the window hides, mark inactive and emit signal
    Connections {
        target: targetWindow
        ignoreUnknownSignals: true
        
        function onVisibleChanged() {
            if (!targetWindow) return
            root.isActive = targetWindow.visible
            if (!targetWindow.visible) {
                root.focusLost()
            }
        }
    }
}

