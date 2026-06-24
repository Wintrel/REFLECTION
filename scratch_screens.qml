import QtQuick
import Quickshell

ShellRoot {
    Component.onCompleted: {
        console.log("Screens count:", Quickshell.screens.length);
        for (var i = 0; i < Quickshell.screens.length; i++) {
            var s = Quickshell.screens[i];
            console.log("Screen " + i + ": " + s.name + " (" + s.width + "x" + s.height + ") at " + s.x + "," + s.y);
        }
        Qt.quit();
    }
}
