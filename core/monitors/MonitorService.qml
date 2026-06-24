pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject primaryScreen: null

    function updatePrimaryScreen() {
        var screens = Quickshell.screens;
        if (!screens || screens.length === 0) {
            primaryScreen = null;
            return;
        }
        
        // Option C: Find the first external monitor (name doesn't start with eDP)
        for (var i = 0; i < screens.length; ++i) {
            if (screens[i].name && !screens[i].name.startsWith("eDP")) {
                primaryScreen = screens[i];
                return;
            }
        }
        
        // Fallback to the first available screen (usually the internal laptop screen)
        primaryScreen = screens[0];
    }

    // Instantiator perfectly tracks additions/removals to the list model,
    // which normal QML property bindings in JS loops fail to do.
    Instantiator {
        model: Quickshell.screens
        delegate: QtObject {}
        onObjectAdded: root.updatePrimaryScreen()
        onObjectRemoved: root.updatePrimaryScreen()
    }

    Component.onCompleted: updatePrimaryScreen()
}
