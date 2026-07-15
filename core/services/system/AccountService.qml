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
    property string bannerPicture: ""
    
    // New properties
    property string uid: ""
    property string gid: ""
    property string loginShell: ""
    property var availableShells: []
    property var sshKeys: []
    property var storageUsage: ({ size: "0G", used: "0G", avail: "0G", percent: 0 })
    property var userGroupsList: []
    property var activeSessions: []
    
    property bool isLoaded: false
    
    // Static Process for fetching info
    Process {
        id: procInfo
        command: ["sh", "-c", "echo \"$(id -un)|$(getent passwd $(id -un) | cut -d: -f5 | cut -d, -f1)|$(id -Gn $(id -un))|$(id -u)|$(id -g)|$(getent passwd $(id -un) | cut -d: -f7)\""]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|");
                root.username = parts[0] || "";
                root.realName = parts[1] || root.username;
                root.groups = (parts[2] || "").split(" ").join(", ");
                root.userGroupsList = (parts[2] || "").split(" ");
                root.uid = parts[3] || "";
                root.gid = parts[4] || "";
                root.loginShell = parts[5] || "";
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
    
    // Static Process for checking banner
    Process {
        id: procBannerCheck
        command: ["sh", "-c", "if [ -f ~/.face_banner ]; then echo \"file://$HOME/.face_banner\"; fi"]
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim();
                if (path.length > 0) {
                    root.bannerPicture = path + "?t=" + new Date().getTime();
                } else {
                    root.bannerPicture = "";
                }
            }
        }
    }
    
    // Static Process for picking and setting banner
    Process {
        id: procSetBanner
        command: ["sh", "-c", "FILE=$(zenity --file-selection --title=\"Select Banner Picture\" 2>/dev/null); if [ -n \"$FILE\" ]; then cp \"$FILE\" ~/.face_banner; echo \"SUCCESS\"; fi"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "SUCCESS") {
                    root.refreshInfo();
                }
            }
        }
    }
    
    // Process to query available login shells
    Process {
        id: procAvailableShells
        command: ["sh", "-c", "grep -E '^/(usr/)?bin/(bash|zsh|fish|sh)$' /etc/shells | paste -sd '|'"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("|");
                var seen = {};
                for (var i = 0; i < lines.length; i++) {
                    var sh = lines[i].trim();
                    if (sh.length > 0) {
                        var parts = sh.split("/");
                        var base = parts[parts.length - 1];
                        if (!seen[base] || sh.indexOf("/usr/bin/") === 0) {
                            seen[base] = sh;
                        }
                    }
                }
                var uniqueList = [];
                for (var k in seen) {
                    uniqueList.push(seen[k]);
                }
                uniqueList.sort(function(a, b) {
                    return a.split("/").pop().localeCompare(b.split("/").pop());
                });
                root.availableShells = uniqueList;
            }
        }
    }
    
    // Process to scan ~/.ssh for public keys
    Process {
        id: procSSHKeys
        command: ["python3", "-c", "import os, glob, json; keys = []; [keys.append({'name': os.path.basename(f), 'content': open(f).read().strip()}) for f in glob.glob(os.path.expanduser('~/.ssh/*.pub')) if os.path.isfile(f)]; print(json.dumps(keys))"]
        stdout: SplitParser {
            onRead: data => {
                var json;
                try {
                    json = JSON.parse(data.trim());
                } catch(e) {
                    return;
                }
                var list = [];
                for (var i = 0; i < json.length; i++) {
                    var name = json[i].name;
                    var content = json[i].content;
                    var keyParts = content.trim().split(/\s+/);
                    var type = "SSH Key";
                    var comment = "";
                    if (keyParts.length > 0) {
                        var algo = keyParts[0].replace("ssh-", "").toUpperCase();
                        type = algo;
                    }
                    if (keyParts.length > 2) {
                        comment = keyParts.slice(2).join(" ");
                    } else if (keyParts.length === 2 && !keyParts[1].match(/^[A-Za-z0-9+/=]+$/)) {
                        comment = keyParts[1];
                    }
                    list.push({
                        name: name,
                        content: content,
                        type: type,
                        comment: comment
                    });
                }
                root.sshKeys = list;
            }
        }
    }
    
    // Process to check storage usage
    Process {
        id: procStorage
        command: ["sh", "-c", "df -h ~ | tail -n 1"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                var parts = line.split(/\s+/);
                if (parts.length >= 5) {
                    var size = parts[1];
                    var used = parts[2];
                    var avail = parts[3];
                    var pctStr = parts[4].replace("%", "");
                    var percent = parseInt(pctStr) || 0;
                    root.storageUsage = {
                        size: size,
                        used: used,
                        avail: avail,
                        percent: percent
                    };
                }
            }
        }
    }
    
    // Process to query active user sessions
    Process {
        id: procSessions
        command: ["python3", "-c", "import subprocess, json, datetime, time\ndef get_duration(t_str):\n    try:\n        parts = t_str.split()\n        if len(parts) >= 3:\n            dt = datetime.datetime.strptime(parts[1] + ' ' + parts[2], '%Y-%m-%d %H:%M:%S')\n            diff = int(time.time() - dt.timestamp())\n            if diff < 0: return '0s'\n            if diff < 60: return f'{diff}s'\n            minutes = diff // 60\n            if minutes < 60: return f'{minutes}m'\n            hours = minutes // 60\n            if hours < 24: return f'{hours}h {minutes % 60}m'\n            days = hours // 24\n            return f'{days}d {hours % 24}h'\n    except: pass\n    return ''\nsessions = []\ntry:\n    out = subprocess.check_output(['loginctl', 'list-sessions', '--no-legend']).decode().strip()\n    for line in out.split('\\n'):\n        parts = line.split()\n        if not parts: continue\n        sid = parts[0]\n        s_out = subprocess.check_output(['loginctl', 'show-session', sid]).decode().strip()\n        s_details = {}\n        for s_line in s_out.split('\\n'):\n            if '=' in s_line:\n                k, v = s_line.split('=', 1)\n                s_details[k] = v\n        if s_details.get('Class') == 'user':\n            t_str = s_details.get('Timestamp', '')\n            sessions.append({\n                'id': sid,\n                'tty': s_details.get('TTY', ''),\n                'type': s_details.get('Type', ''),\n                'desktop': s_details.get('Desktop', ''),\n                'service': s_details.get('Service', ''),\n                'active': s_details.get('Active', '') == 'yes',\n                'timestamp': t_str,\n                'duration': get_duration(t_str)\n            })\nexcept Exception as e: pass\nprint(json.dumps(sessions))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.activeSessions = JSON.parse(data.trim());
                } catch(e) {}
            }
        }
    }
    
    Component.onCompleted: {
        refreshInfo();
    }
    
    function refreshInfo() {
        procInfo.running = true;
        procPicCheck.running = true;
        procBannerCheck.running = true;
        procAvailableShells.running = true;
        procSSHKeys.running = true;
        procStorage.running = true;
        procSessions.running = true;
        root.isLoaded = true;
    }
    
    function terminateSession(sessionId) {
        if (!sessionId) return;
        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        p.command = ["loginctl", "terminate-session", sessionId];
        p.exited.connect(function(code) {
            root.refreshInfo();
            p.destroy();
        });
        p.running = true;
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
    
    function setShell(shellPath) {
        if (!shellPath || shellPath === root.loginShell) return;
        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        p.command = ["pkexec", "chsh", "-s", shellPath, root.username];
        p.exited.connect(function(code) {
            if (code === 0) {
                root.refreshInfo();
                State.GlobalStates.notificationTriggered();
            }
            p.destroy();
        });
        p.running = true;
    }
    
    function toggleGroupMembership(groupName, isMember) {
        if (!groupName) return;
        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        if (isMember) {
            p.command = ["pkexec", "gpasswd", "-a", root.username, groupName];
        } else {
            p.command = ["pkexec", "gpasswd", "-d", root.username, groupName];
        }
        p.exited.connect(function(code) {
            if (code === 0) {
                root.refreshInfo();
                State.GlobalStates.notificationTriggered();
            }
            p.destroy();
        });
        p.running = true;
    }
    
    function copyToClipboard(text) {
        if (!text) return;
        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        p.command = ["wl-copy"];
        p.stdinEnabled = true;
        p.running = true;
        p.write(text);
        p.stdinEnabled = false;
        p.exited.connect(function() { p.destroy(); });
    }
    
    function pickAndSetProfilePicture() {
        procSetPic.running = true;
    }
    
    function pickAndSetBannerPicture() {
        procSetBanner.running = true;
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

    Timer {
        id: livePollTimer
        interval: 5000 // Poll every 5 seconds
        running: State.GlobalStates.settingsOpen
        repeat: true
        onTriggered: {
            procSessions.running = true;
            procStorage.running = true;
        }
    }
}
