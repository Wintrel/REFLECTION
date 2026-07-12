import QtQuick
import Qt5Compat.GraphicalEffects
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
            
            scale: appMa.pressed ? 0.9 : (appMa.containsMouse ? 1.15 : 1)
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
            
            // App Glow (active on hover)
            RectangularGlow {
                anchors.fill: parent
                glowRadius: 15
                spread: 0.1
                color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.3) : "#4d6e8fc0"
                opacity: appMa.containsMouse ? 1.0 : 0
                visible: opacity > 0
                layer.enabled: true
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
            
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
            Item {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -6
                anchors.horizontalCenter: parent.horizontalCenter
                width: modelData.count > 1 ? (appMa.containsMouse ? 24 : 16) : 0
                height: 3
                visible: modelData.count > 1
                
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
                
                RectangularGlow {
                    anchors.fill: indicatorRect
                    glowRadius: 6
                    spread: 0.2
                    color: root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.5) : "#80FFFFFF"
                    layer.enabled: true
                }
                
                Rectangle {
                    id: indicatorRect
                    anchors.fill: parent
                    radius: 1.5
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
            }
            
            MouseArea {
                id: appMa
                anchors.fill: parent
                hoverEnabled: true
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
