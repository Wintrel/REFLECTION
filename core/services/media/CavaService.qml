pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    
    // Toggle this property to start/stop the Cava process
    property bool active: false
    
    // The live array of audio frequency values (0.0 to 1.0)
    property var values: []
    
    property Process process: Process {
        command: ["cava", "-p", "/home/wintrel/Documents/REFLECTION/config/cava_raw"]
        running: root.active
        
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return;
                
                var parts = data.split(";");
                if (parts.length > 0 && parts[parts.length - 1] === "") {
                    parts.pop();
                }
                
                var newValues = [];
                for (var i = 0; i < parts.length; i++) {
                    var val = parseInt(parts[i]);
                    if (!isNaN(val)) {
                        // Divide by 100 since ascii_max_range = 100 in config
                        newValues.push(val / 100.0);
                    }
                }
                
                if (newValues.length > 0) {
                    root.values = newValues;
                }
            }
        }
    }
}
