pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    // Arrays of objects representing state
    property var workspaces: []
    property var clients: []
    property int activeWorkspaceId: 1
    
    // Whether the active workspace has any windows
    property bool isWorkspaceEmpty: true
    
    // Icon cache maps window class to absolute file:// path
    property var iconCache: ({})
    
    function resolveIcon(className) {
        if (iconCache[className] !== undefined) return;
        iconCache[className] = ""; // mark as loading
        var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["python3", "-c", "import sys, gi; gi.require_version(\'Gtk\', \'3.0\'); from gi.repository import Gtk; t = Gtk.IconTheme.get_default(); c = sys.argv[1]; res = next((i.get_filename() for cand in [c, c.lower(), c.split(\'.\')[-1], c.split(\'.\')[-1].lower()] if (i := t.lookup_icon(cand, 64, 0))), \'\'); print(res)", "' + className + '"]; stdout: SplitParser { onRead: data => { var path = data.trim(); if (path) { var newCache = Object.assign({}, root.iconCache); newCache["' + className + '"] = "file://" + path; root.iconCache = newCache; } } } }', root);
        p.exited.connect(function() { p.destroy(); });
        p.running = true;
    }
    
    Process {
        id: stateDaemon
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/reflection/scripts/hypr_daemon.py"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    var state = JSON.parse(data);
                    
                    var ws = state.workspaces;
                    ws.sort((a, b) => a.id - b.id);
                    root.workspaces = ws;
                    
                    var cls = state.clients;
                    root.clients = cls;
                    
                    var activeId = state.activeWorkspace.id;
                    root.activeWorkspaceId = activeId;
                    
                    var hasWindows = false;
                    for (var i = 0; i < cls.length; i++) {
                        if (cls[i].class) {
                            root.resolveIcon(cls[i].class);
                        }
                        if (cls[i].workspace.id === activeId) {
                            hasWindows = true;
                        }
                    }
                    root.isWorkspaceEmpty = !hasWindows;
                } catch (e) {
                    console.log("HyprlandService Error parsing state: " + e);
                }
            }
        }
        onRunningChanged: {
            if (!running) running = true;
        }
    }
    
    function fetchState() {
        // Handled entirely by the daemon now
    }
    
    Component.onCompleted: {
        // Handled entirely by the daemon now
    }
}
