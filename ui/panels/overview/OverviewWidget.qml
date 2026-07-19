import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import "../../../core/services/system" as System
import "../../../core/state" as State

Item {
    id: root
    property var theme
    property bool overviewVisible: false

    // Grid config from theme
    property int rows: theme.overviewRows
    property int columns: theme.overviewColumns
    property real overviewScale: theme.overviewScale

    // Get this specific monitor's dimensions for sizing, fallback to monitor 0
    property string targetMonitorName: ""
    property var primaryMonitor: System.HyprlandService.monitors.find(
        m => m.name === targetMonitorName
    ) || System.HyprlandService.monitors[0] || null
    property real monW: primaryMonitor ? (primaryMonitor.width / (primaryMonitor.scale || 1)) : 1920
    property real monH: primaryMonitor ? (primaryMonitor.height / (primaryMonitor.scale || 1)) : 1080

    // Workspace block sizing — proportional to monitor aspect ratio
    property real wsBlockWidth: monW * overviewScale
    property real wsBlockHeight: monH * overviewScale
    property real wsSpacing: 6

    // Total widget size
    implicitWidth: backgroundRect.width
    implicitHeight: backgroundRect.height

    // Helper: dispatch hyprland lua commands
    function dispatch(luaCmd) {
        var escapedCmd = luaCmd.replace(/"/g, '\\"');
        var p = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["hyprctl", "dispatch", "' + escapedCmd + '"] }',
            root
        );
        p.exited.connect(function() { p.destroy(); });
        p.running = true;
    }

    // Helper: find monitor data for a workspace
    function monitorForWorkspace(wsId) {
        var ws = System.HyprlandService.workspaces.find(w => w.id === wsId);
        if (!ws) return primaryMonitor;
        var mon = System.HyprlandService.monitors.find(m => m.name === ws.monitor);
        return mon || primaryMonitor;
    }

    // Which workspace group we're viewing (based on active workspace)
    property int workspacesPerPage: rows * columns
    property int workspaceGroup: Math.floor((System.HyprlandService.activeWorkspaceId - 1) / workspacesPerPage)

    // Get workspace ID for a given grid cell
    function wsIdForCell(row, col) {
        return workspaceGroup * workspacesPerPage + row * columns + col + 1;
    }

    // Drag state tracking
    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1

    // Map of toplevels for O(1) lookup in WindowPreviews
    property var toplevelMap: {
        var map = {};
        if (ToplevelManager && ToplevelManager.toplevels) {
            var tops = ToplevelManager.toplevels.values;
            if (tops) {
                for (var i = 0; i < tops.length; ++i) {
                    var t = tops[i];
                    var addr = t.HyprlandToplevel ? t.HyprlandToplevel.address : null;
                    if (addr) {
                        map["0x" + addr] = t;
                    }
                }
            }
        }
        return map;
    }

    // Animate in
    opacity: overviewVisible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo } }
    scale: overviewVisible ? 1.0 : 0.95
    Behavior on scale { NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo } }
    transformOrigin: Item.Top

    // Drop shadow for the overview panel
    DropShadow {
        anchors.fill: backgroundRect
        source: backgroundRect
        radius: 32
        samples: 33
        color: Qt.rgba(0, 0, 0, 0.5)
        verticalOffset: 12
        transparentBorder: true
        z: -1
    }

    // Background container
    Rectangle {
        id: backgroundRect
        property real padding: 12
        width: gridLayout.width + padding * 2
        height: gridLayout.height + padding * 2
        radius: theme.radiusIsland
        color: Qt.rgba(
            theme.bgBezel.r || 0,
            theme.bgBezel.g || 0,
            theme.bgBezel.b || 0,
            0.85
        )
        border.color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1

        // Grid of workspaces
        Column {
            id: gridLayout
            anchors.centerIn: parent
            spacing: root.wsSpacing
            
            scale: root.overviewVisible ? 1.0 : 0.95
            opacity: root.overviewVisible ? 1.0 : 0.0
            
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

            Repeater {
                model: root.rows

                Row {
                    id: gridRow
                    required property int index
                    property int rowIndex: index
                    spacing: root.wsSpacing

                    Repeater {
                        model: root.columns

                        WorkspaceBlock {
                            required property int index
                            property int colIndex: index
                            
                            wsId: root.wsIdForCell(gridRow.rowIndex, colIndex)
                            isActive: System.HyprlandService.activeWorkspaceId === wsId
                            theme: root.theme
                            overviewRoot: root
                            gridLayoutObj: gridLayout
                        }
                    }
                }
            }
        }

        // Active workspace indicator overlay
        Rectangle {
            id: activeIndicator
            property int activeRow: Math.floor((System.HyprlandService.activeWorkspaceId - 1 - root.workspaceGroup * root.workspacesPerPage) / root.columns)
            property int activeCol: (System.HyprlandService.activeWorkspaceId - 1 - root.workspaceGroup * root.workspacesPerPage) % root.columns
            
            x: backgroundRect.padding + activeCol * (root.wsBlockWidth + root.wsSpacing)
            y: backgroundRect.padding + activeRow * (root.wsBlockHeight + root.wsSpacing)
            width: root.wsBlockWidth
            height: root.wsBlockHeight
            radius: theme.radiusIsland * 0.5
            color: Qt.rgba(theme.accentPrimary.r || 0, theme.accentPrimary.g || 0, theme.accentPrimary.b || 0, 0.15)
            border.color: theme.accentPrimary
            border.width: 2
            z: 10

            visible: activeRow >= 0 && activeRow < root.rows && activeCol >= 0 && activeCol < root.columns

            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
        }
    }
}
