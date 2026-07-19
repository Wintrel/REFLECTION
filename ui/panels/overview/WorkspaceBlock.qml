import QtQuick
import Quickshell
import "../../../core/services/system" as System
import "../../../core/state" as State

Rectangle {
    id: wsBlock
    required property int wsId
    required property bool isActive
    required property var theme
    required property var overviewRoot
    required property var gridLayoutObj

    property bool hoveredWhileDragging: false

    width: overviewRoot.wsBlockWidth
    height: overviewRoot.wsBlockHeight
    radius: theme.radiusIsland * 0.5
    z: overviewRoot.draggingFromWorkspace === wsId ? 100 : 0
    color: hoveredWhileDragging ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03)
    border.color: isActive ? theme.accentPrimary : Qt.rgba(1, 1, 1, 0.06)
    border.width: isActive ? 2 : 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 200 } }

    // Workspace number watermark
    Text {
        anchors.centerIn: parent
        text: wsBlock.wsId
        font.pixelSize: overviewRoot.wsBlockHeight * 0.4
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
            overviewRoot.dispatch('hl.dsp.focus({ workspace = "' + wsBlock.wsId + '" })');
        }
    }

    // Drop target
    DropArea {
        anchors.fill: parent
        onEntered: {
            overviewRoot.draggingTargetWorkspace = wsBlock.wsId;
            if (overviewRoot.draggingFromWorkspace !== wsBlock.wsId)
                wsBlock.hoveredWhileDragging = true;
        }
        onExited: {
            wsBlock.hoveredWhileDragging = false;
            if (overviewRoot.draggingTargetWorkspace === wsBlock.wsId)
                overviewRoot.draggingTargetWorkspace = -1;
        }
    }

    // Window preview layer — positioned inside the workspace block
    Item {
        id: windowLayer
        anchors.fill: parent
        clip: overviewRoot.draggingFromWorkspace !== wsBlock.wsId

        // Monitor info for this workspace
        property var mon: overviewRoot.monitorForWorkspace(wsBlock.wsId)
        property real mW: mon ? (mon.width / (mon.scale || 1)) : overviewRoot.monW
        property real mH: mon ? (mon.height / (mon.scale || 1)) : overviewRoot.monH
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

                delegate: WindowPreview {
                    modelData: modelData
                    theme: wsBlock.theme
                    overviewRoot: wsBlock.overviewRoot
                    gridLayoutObj: wsBlock.gridLayoutObj
                    wsBlockId: wsBlock.wsId
                    mX: windowLayer.mX
                    mY: windowLayer.mY
                    mW: windowLayer.mW
                    mH: windowLayer.mH
                    scaleFactor: windowLayer.scaleFactor
                }
            }
        }
    }
}
