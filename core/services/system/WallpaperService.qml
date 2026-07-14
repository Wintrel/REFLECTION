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
            refreshWallpapers(); // Scan wallpapers on startup
        }
    }
    
    property var wallpapers: []
    property string currentWallpaper: ""
    
    // Load saved wallpaper path on startup
    Process {
        command: ["sh", "-c", "cat /home/wintrel/.config/quickshell/reflection/.current_wallpaper 2>/dev/null || true"]
        stdout: SplitParser {
            onRead: data => { 
                if (data.trim() !== "") root.currentWallpaper = data.trim(); 
            }
        }
        running: true
    }
    
    function refreshWallpapers() {
        var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        p.command = ["sh", "-c", "ls -1 ~/Pictures/Wallpapers | grep -iE '\\.(png|jpg|jpeg|gif|webp)$' || true"];
        
        var outputData = "";
        
        var parser = Qt.createQmlObject('import Quickshell.Io; SplitParser { }', p);
        parser.read.connect(function(data) {
            outputData += data + "\n";
        });
        p.stdout = parser;
        
        p.exited.connect(function() {
            var files = outputData.trim().split('\n');
            var newList = [];
            for (var i = 0; i < files.length; i++) {
                if (files[i] && files[i].trim() !== "") {
                    newList.push("file:///home/wintrel/Pictures/Wallpapers/" + files[i].trim());
                }
            }
            root.wallpapers = newList;
            p.destroy();
        });
        
        p.running = true;
    }
    
    function setWallpaper(imagePath, transitionType) {
        var trans = transitionType ? transitionType : "wipe";
        
        root.currentWallpaper = imagePath;
        
        // Save the selection
        var p2 = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        p2.command = ["sh", "-c", "echo '" + imagePath + "' > /home/wintrel/.config/quickshell/reflection/.current_wallpaper"];
        p2.running = true;
        
        var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        // Extract the raw path from the file:/// url
        var rawPath = imagePath.replace("file://", "");
        p.command = ["awww", "img", rawPath, "--transition-type", trans];
        p.running = true;
    }
}
