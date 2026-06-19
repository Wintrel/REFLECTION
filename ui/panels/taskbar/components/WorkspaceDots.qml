import QtQuick
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
                if (ws[i].id > maxId && ws[i].id < 100) {
                    maxId = ws[i].id;
                }
            }
            return maxId;
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
            
            width: isActive ? 24 : 8
            height: 8
            radius: 4
            
            color: root.theme ? root.theme.accentWorkspace : '#ffffff'
            opacity: isActive ? 1.0 : (isOccupied ? 0.4 : 0.1)
            
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4 // larger hit area
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "dispatch", "hl.dsp.focus({ workspace = \\"' + dot.wsId + '\\" })"] }', root);
                    p.running = true;
                }
            }
        }
    }
}
