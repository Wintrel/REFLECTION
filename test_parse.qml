import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Window {
        width: 400; height: 400
        visible: true
        
        property string buf: ""
        
        Process {
            command: ["hyprctl", "workspaces", "-j"]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    buf += data;
                    try {
                        var j = JSON.parse(buf);
                        console.log("SUCCESS! " + j.length);
                        Qt.quit();
                    } catch(e) {
                        console.log("Failed to parse: " + buf.length);
                    }
                }
            }
        }
        
        Timer {
            interval: 2000; running: true
            onTriggered: { console.log("Timeout! Buffer: " + buf.substring(0, 100)); Qt.quit(); }
        }
    }
}
