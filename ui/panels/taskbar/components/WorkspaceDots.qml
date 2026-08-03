import QtQuick
import "../../../components"
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../core/services/system" as System

Row {
    id: root
    spacing: 12
    
    property var theme
    
    // We only want to show normal workspaces (IDs 1-10 usually), not special ones
    Repeater {
        // Find the maximum workspace ID to determine how many dots to show
        // Or just hardcode 5 or 10 if preferred. Let's show up to max occupied or minimum 5.
        model: {
            var maxId = 5;
            var ws = System.HyprlandService.workspaces;
            for (var i = 0; i < ws.length; i++) {
                // Ignore special ambient workspaces (e.g. 90+) by capping at 10
                if (ws[i].id > maxId && ws[i].id <= 10) {
                    maxId = ws[i].id;
                }
            }
            return maxId;
        }
        
        Item {
            width: dot.width
            height: dot.height

            RectangularGlow {
                anchors.fill: dot
                glowRadius: 10
                spread: 0.1
                color: root.theme ? Qt.rgba(root.theme.accentWorkspace.r, root.theme.accentWorkspace.g, root.theme.accentWorkspace.b, 0.6) : "#99ffffff"
                opacity: dot.isActive ? 1.0 : 0
                visible: opacity > 0
                layer.enabled: true
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }

            Rectangle {
                id: dot
                property int wsId: index + 1
                property bool isActive: System.HyprlandService.activeWorkspaceId === wsId
                property bool isOccupied: {
                    var ws = System.HyprlandService.workspaces;
                    for (var i = 0; i < ws.length; i++) {
                        if (ws[i].id === wsId && ws[i].windows > 0) return true;
                    }
                    return false;
                }
                
                width: System.ShellService.workspaceNumbers ? 20 : (isActive ? 24 : 8)
                height: System.ShellService.workspaceNumbers ? 20 : 8
                radius: height / 2
                
                color: root.theme ? root.theme.accentWorkspace : '#ffffff'
                opacity: isActive ? 1.0 : (isOccupied ? 0.4 : 0.1)
                
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                ReflectionGradient {
                    theme: root.theme
                    startColor: parent.color
                    endColor: dot.isActive && root.theme ? root.theme.accentPrimaryGradientEnd : parent.color
                    anchors.fill: parent
                    visible: root.theme && root.theme.useGradients && dot.isActive
                }

                Text {
                    anchors.centerIn: parent
                    visible: System.ShellService.workspaceNumbers
                    text: dot.wsId
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.bgBase : "#000"
                }
            }
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4 // larger hit area
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "dispatch", "hl.dsp.focus({ workspace = \\"' + dot.wsId + '\\" })"] ; onExited: destroy() }', root);
                    p.exited.connect(function() { p.destroy(); });
                    p.running = true;
                }
            }
        }
    }
}
