import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../about" as About

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true

    function runCheckUpdates() {
        var procStr = 'import QtQuick; import Quickshell.Io; Process { command: ["checkupdates"] }';
        var proc = Qt.createQmlObject(procStr, root);
        var parserStr = 'import QtQuick; import Quickshell.Io; SplitParser { }';
        var parser = Qt.createQmlObject(parserStr, proc);
        proc.stdout = parser;
        
        var tempPackages = [];
        parser.read.connect(function(data) {
            var line = data.trim();
            if (line === "") return;
            var parts = line.split(/\s+/);
            if (parts.length >= 4 && parts[parts.length - 2] === "->") {
                tempPackages.push({
                    name: parts[0],
                    oldVer: parts[1],
                    newVer: parts[parts.length - 1]
                });
            }
        });
        
        proc.exited.connect(function(code) {
            var getWeight = function(pkg) {
                var n = pkg.name;
                if (n.startsWith("linux") && !n.endsWith("docs")) return 100;
                if (n === "systemd" || n === "wayland" || n === "xorg-server") return 90;
                if (n === "mesa" || n.startsWith("nvidia") || n.startsWith("amd") || n.startsWith("vulkan")) return 80;
                if (n === "glibc" || n === "pacman") return 70;
                if (n === "firefox" || n === "kitty" || n === "chromium") return 60;
                return 0;
            };
            
            tempPackages.sort(function(a, b) {
                var wa = getWeight(a);
                var wb = getWeight(b);
                if (wa !== wb) return wb - wa; // Highest weight first
                return a.name.localeCompare(b.name);
            });
            
            systemUpdateHeader.updatePackages = tempPackages;
            // checkupdates exits with 2 if no updates, 0 if updates found (or vice-versa in some versions)
            systemUpdateHeader.updateState = tempPackages.length > 0 ? 2 : 0;
            proc.destroy();
        });
        
        proc.running = true;
    }
    
    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: colLayout.implicitHeight
        clip: true
        
        flickDeceleration: 1000
        maximumFlickVelocity: 4000
        boundsBehavior: Flickable.DragAndOvershootBounds
        
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        
        ColumnLayout {
            id: colLayout
            width: parent.width
            spacing: 32
            
            // System Update Interactive Header
            UpdateHeader {
                id: systemUpdateHeader
                theme: root.theme
                iconName: "system_update"
                title: "System Update"
                
                onCheckUpdatesRequested: {
                    root.runCheckUpdates();
                }
            }

            // Reflection Update Compact Card
            ReflectionUpdateCard {
                theme: root.theme
            }
        }
    }
}
