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

    // Get the primary monitor's dimensions for sizing
    property var primaryMonitor: System.HyprlandService.monitors.find(
        m => m.name === (Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "")
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

    // Helper: dispatch hyprctl commands
    function dispatch(cmd, arg) {
        var p = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["hyprctl", "dispatch", "' + cmd + '", "' + arg + '"] }',
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

    // Animate in
    opacity: overviewVisible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo } }
    scale: overviewVisible ? 1.0 : 0.95
    Behavior on scale { NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutExpo } }
    transformOrigin: Item.Top

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

            Repeater {
                model: root.rows

                Row {
                    id: gridRow
                    required property int index
                    property int rowIndex: index
                    spacing: root.wsSpacing

                    Repeater {
                        model: root.columns

                        Rectangle {
                            id: wsBlock
                            required property int index
                            property int colIndex: index
                            property int wsId: root.wsIdForCell(gridRow.rowIndex, colIndex)
                            property bool isActive: System.HyprlandService.activeWorkspaceId === wsId
                            property bool hoveredWhileDragging: false

                            width: root.wsBlockWidth
                            height: root.wsBlockHeight
                            radius: theme.radiusIsland * 0.5
                            color: hoveredWhileDragging ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03)
                            border.color: isActive ? theme.accentPrimary : Qt.rgba(1, 1, 1, 0.06)
                            border.width: isActive ? 2 : 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            // Workspace number watermark
                            Text {
                                anchors.centerIn: parent
                                text: wsBlock.wsId
                                font.pixelSize: root.wsBlockHeight * 0.4
                                font.bold: true
                                color: theme.textSub
                                opacity: 0.06
                            }

                            // Click to switch workspace
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: {
                                    State.GlobalStates.overviewOpen = false;
                                    root.dispatch("workspace", wsBlock.wsId);
                                }
                            }

                            // Drop target
                            DropArea {
                                anchors.fill: parent
                                onEntered: {
                                    root.draggingTargetWorkspace = wsBlock.wsId;
                                    if (root.draggingFromWorkspace !== wsBlock.wsId)
                                        wsBlock.hoveredWhileDragging = true;
                                }
                                onExited: {
                                    wsBlock.hoveredWhileDragging = false;
                                    if (root.draggingTargetWorkspace === wsBlock.wsId)
                                        root.draggingTargetWorkspace = -1;
                                }
                            }

                            // Window preview layer — positioned inside the workspace block
                            Item {
                                id: windowLayer
                                anchors.fill: parent
                                clip: true

                                // Monitor info for this workspace
                                property var mon: root.monitorForWorkspace(wsBlock.wsId)
                                property real mW: mon ? (mon.width / (mon.scale || 1)) : root.monW
                                property real mH: mon ? (mon.height / (mon.scale || 1)) : root.monH
                                property real mX: mon ? (mon.x || 0) : 0
                                property real mY: mon ? (mon.y || 0) : 0

                                // Scale factor to fit monitor space into the block
                                property real scaleFactor: Math.min(width / mW, height / mH)

                                // Centered viewport
                                Item {
                                    id: viewport
                                    width: windowLayer.mW * windowLayer.scaleFactor
                                    height: windowLayer.mH * windowLayer.scaleFactor
                                    anchors.centerIn: parent

                                    Repeater {
                                        model: System.HyprlandService.clients.filter(
                                            w => w.mapped && w.workspace && w.workspace.id === wsBlock.wsId
                                        )

                                        delegate: Item {
                                            id: windowItem
                                            required property var modelData
                                            property string windowAddress: modelData.address

                                            // Position relative to monitor
                                            x: Math.max(0, (modelData.at[0] - windowLayer.mX) * windowLayer.scaleFactor)
                                            y: Math.max(0, (modelData.at[1] - windowLayer.mY) * windowLayer.scaleFactor)
                                            width: Math.max(12, (modelData.size[0] || 0) * windowLayer.scaleFactor)
                                            height: Math.max(12, (modelData.size[1] || 0) * windowLayer.scaleFactor)

                                            z: windowDragArea.drag.active ? 9999 : (modelData.floating ? 2 : 1)
                                            Drag.active: windowDragArea.drag.active
                                            Drag.source: windowItem
                                            Drag.hotSpot.x: width / 2
                                            Drag.hotSpot.y: height / 2

                                            Rectangle {
                                                id: windowVisual
                                                anchors.fill: parent
                                                radius: Math.max(4, 8 * windowLayer.scaleFactor)
                                                color: Qt.rgba(0, 0, 0, 0.45)
                                                border.color: windowDragArea.containsMouse ? theme.accentPrimary : Qt.rgba(1, 1, 1, 0.1)
                                                border.width: 1
                                                clip: true

                                                // Look up ToplevelManager entry for live preview
                                                property var toplevel: {
                                                    if (!ToplevelManager || !ToplevelManager.toplevels) return null;
                                                    var tops = ToplevelManager.toplevels.values;
                                                    if (!tops) return null;
                                                    for (var i = 0; i < tops.length; ++i) {
                                                        var t = tops[i];
                                                        var addr = t.HyprlandToplevel ? t.HyprlandToplevel.address : null;
                                                        if (addr && ("0x" + addr) === windowItem.windowAddress) return t;
                                                    }
                                                    return null;
                                                }

                                                ScreencopyView {
                                                    id: screencopy
                                                    anchors.fill: parent
                                                    captureSource: (root.overviewVisible && windowVisual.toplevel) ? windowVisual.toplevel : null
                                                    live: true
                                                }

                                                // Fallback icon when screencopy hasn't rendered
                                                Image {
                                                    visible: !screencopy.hasContent
                                                    property real iconSize: Math.min(32, Math.min(parent.width, parent.height) * 0.5)
                                                    source: {
                                                        var cls = modelData.class || "";
                                                        if (!cls) return Quickshell.iconPath("image-missing", "image-missing");
                                                        var cached = System.HyprlandService.iconCache[cls];
                                                        if (cached) return cached;
                                                        return Quickshell.iconPath(cls, "image-missing");
                                                    }
                                                    width: iconSize
                                                    height: iconSize
                                                    anchors.centerIn: parent
                                                    sourceSize: Qt.size(iconSize, iconSize)
                                                    mipmap: true
                                                }

                                                // Hover color overlay
                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: parent.radius
                                                    color: windowDragArea.containsMouse ? theme.accentPrimary : "transparent"
                                                    opacity: 0.15
                                                }
                                            }

                                            MouseArea {
                                                id: windowDragArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                                drag.target: parent

                                                onPressed: (mouse) => {
                                                    root.draggingFromWorkspace = wsBlock.wsId;
                                                    windowItem.Drag.active = true;
                                                }
                                                onReleased: {
                                                    var target = root.draggingTargetWorkspace;
                                                    windowItem.Drag.active = false;
                                                    root.draggingFromWorkspace = -1;

                                                    if (target !== -1 && target !== wsBlock.wsId) {
                                                        root.dispatch("movetoworkspacesilent", target + ",address:" + windowItem.windowAddress);
                                                    }
                                                }
                                                onClicked: (event) => {
                                                    if (event.button === Qt.LeftButton) {
                                                        State.GlobalStates.overviewOpen = false;
                                                        root.dispatch("focuswindow", "address:" + windowItem.windowAddress);
                                                    } else if (event.button === Qt.MiddleButton) {
                                                        root.dispatch("closewindow", "address:" + windowItem.windowAddress);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
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
            color: "transparent"
            border.color: theme.accentPrimary
            border.width: 2
            z: 10

            visible: activeRow >= 0 && activeRow < root.rows && activeCol >= 0 && activeCol < root.columns

            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
        }
    }
}
