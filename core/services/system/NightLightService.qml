pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool isEnabled: false

    Process {
        id: wlsunsetProcess
        command: ["wlsunset", "-T", "4500"]
        // Doesn't run automatically1
        running: false
    }

    function toggleNightLight() {
        isEnabled = !isEnabled;
        if (isEnabled) {
            // Ensure any existing instances are killed first
            var killCmd = Qt.createQmlObject('import Quickshell.Io; Process { command: ["killall", "wlsunset"] ; onExited: destroy() }', root);
            killCmd.exited.connect(function() {
                killCmd.destroy();
                wlsunsetProcess.running = true;
            });
            killCmd.running = true;
        } else {
            wlsunsetProcess.running = false;
            var killCmd2 = Qt.createQmlObject('import Quickshell.Io; Process { command: ["killall", "wlsunset"] ; onExited: destroy() }', root);
            killCmd2.exited.connect(function() {
                killCmd2.destroy();
            });
            killCmd2.running = true;
        }
    }
}
