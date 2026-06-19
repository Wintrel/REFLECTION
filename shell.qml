import QtQuick
import Quickshell

import Quickshell.Services.Notifications

ShellRoot {
    id: root
    
    // Load the Dynamic Island
    Loader {
        source: "ui/panels/dynamic_island/DynamicIsland.qml"
    }
}
