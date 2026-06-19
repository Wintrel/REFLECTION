pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    // Starts the awww daemon and binds it to the shell's lifecycle
    Process {
        id: daemonStarter
        command: ["awww-daemon"]
        running: true
    }
    
    // Restore the wallpaper once the daemon is up
    Timer {
        running: true
        interval: 1000
        onTriggered: {
            var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
            p.command = ["awww", "restore"];
            p.running = true;
        }
    }
    
    function setWallpaper(imagePath, transitionType) {
        var trans = transitionType ? transitionType : "simple";
        
        var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        p.command = ["awww", "img", imagePath, "--transition-type", trans];
        p.running = true;
    }
}
