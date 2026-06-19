import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    QtObject {
        id: myRoot
        Component.onCompleted: {
            try {
                var p3 = Qt.createQmlObject('import Quickshell.Io; Process { command: ["notify-send", "Test"] }', myRoot);
                p3.running = true;
                console.log("Success");
            } catch (e) {
                console.log("Error: " + e);
            }
        }
    }
}
