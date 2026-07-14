import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core/state" as State
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    
    property string username: Quickshell.env("USER") || ""
    property string realName: ""
    property string homeDir: Quickshell.env("HOME") || ""
    property string groups: ""
    property string profilePicture: ""
    
    property bool isLoaded: false
    
    // Static Process for fetching info
    Process {
        id: procInfo
        command: ["sh", "-c", "echo \"$(id -un)|$(getent passwd $(id -un) | cut -d: -f5 | cut -d, -f1)|$(id -Gn)\""]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|");
                root.username = parts[0] || "";
                root.realName = parts[1] || root.username;
                root.groups = (parts[2] || "").split(" ").join(", ");
            }
        }
    }
    
    // Static Process for checking picture
    Process {
        id: procPicCheck
        command: ["sh", "-c", "if [ -f ~/.face ]; then echo \"file://$HOME/.face\"; fi"]
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim();
                if (path.length > 0) {
                    root.profilePicture = path + "?t=" + new Date().getTime();
                } else {
                    root.profilePicture = "";
                }
            }
        }
    }
    
    // Static Process for picking and setting picture
    Process {
        id: procSetPic
        command: ["sh", "-c", "FILE=$(zenity --file-selection --title=\"Select Profile Picture\" 2>/dev/null); if [ -n \"$FILE\" ]; then cp \"$FILE\" ~/.face; echo \"SUCCESS\"; fi"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "SUCCESS") {
                    root.refreshInfo();
                }
            }
        }
    }
    
    Component.onCompleted: {
        refreshInfo();
    }
    
    function refreshInfo() {
        procInfo.running = true;
        procPicCheck.running = true;
        root.isLoaded = true;
    }
    
    function setRealName(newName) {
        if (!newName || newName === root.realName) return;
        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        p.command = ["pkexec", "chfn", "-f", newName, root.username];
        p.exited.connect(function(code) {
            if (code === 0) {
                root.refreshInfo();
                State.GlobalStates.notificationTriggered();
            }
            p.destroy();
        });
        p.running = true;
    }
    
    function pickAndSetProfilePicture() {
        procSetPic.running = true;
    }
    
    function setPassword(newPass) {
        if (!newPass) return;
        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        p.command = ["pkexec", "chpasswd"];
        p.stdinEnabled = true;
        p.exited.connect(function(code) {
            if (code === 0) {
                State.GlobalStates.notificationTriggered();
            }
            p.destroy();
        });
        p.running = true;
        p.write(root.username + ":" + newPass + "\n");
        p.stdinEnabled = false;
    }
}
