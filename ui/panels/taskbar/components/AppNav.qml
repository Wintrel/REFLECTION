import QtQuick
import Quickshell
import Quickshell.Io
import "../../../../core/services/system" as System

Row {
    id: root
    spacing: 16
    
    property var theme
    
    // Group clients by class to avoid duplicate icons
    property var uniqueApps: computeUniqueApps(System.HyprlandService.clients)
    
    function computeUniqueApps(cls) {
        if (!cls) return [];
        var map = {};
        var arr = [];
        for (var i = 0; i < cls.length; i++) {
            var c = cls[i];
            if (!c.class || c.class === "") continue;
            // Ignore special layers or hidden windows
            if (c.mapped === false) continue;
            
            if (!map[c.class]) {
                map[c.class] = {
                    "className": c.class,
                    "address": c.address,
                    "count": 1
                };
                arr.push(map[c.class]);
            } else {
                map[c.class].count++;
            }
        }
        return arr;
    }
    
    Repeater {
        model: root.uniqueApps
        
        Item {
            width: 32
            height: 32
            
            // Icon
            Image {
                anchors.centerIn: parent
                width: 28
                height: 28
                sourceSize.width: 28
                sourceSize.height: 28
                // Resolve icon using the python daemon caching
                source: System.HyprlandService.iconCache[modelData.className] || ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                
                // Fallback to text if no icon found
                Text {
                    anchors.centerIn: parent
                    visible: parent.status === Image.Error || parent.source == ""
                    text: modelData.className ? modelData.className.charAt(0).toUpperCase() : "?"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 16
                    font.bold: true
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
            }
            
            // Multiple windows indicator
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -6
                anchors.horizontalCenter: parent.horizontalCenter
                width: 4
                height: 4
                radius: 2
                color: root.theme ? root.theme.textMain : "#FFF"
                visible: modelData.count > 1
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Bypass the broken hyprctl lua syntax parser by directly invoking the internal dispatcher
                    var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "dispatch", "hl.dsp.focus({ window = \\"address:' + modelData.address + '\\" })"] }', root);
                    p.running = true;
                }
            }
        }
    }
}
