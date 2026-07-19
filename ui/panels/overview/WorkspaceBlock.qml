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

    property var wsMonitor: overviewRoot.monitorForWorkspace(wsId)
    property bool isExternalMonitor: wsMonitor ? (wsMonitor.name !== overviewRoot.targetMonitorName) : false

    width: overviewRoot.wsBlockWidth
    height: overviewRoot.wsBlockHeight
    radius: theme.radiusIsland * 0.5
    z: overviewRoot.draggingFromWorkspace === wsId ? 100 : (typeof blockMouseArea !== "undefined" && blockMouseArea.containsMouse ? 10 : 0)
    color: hoveredWhileDragging ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03)
    border.color: isActive ? theme.accentPrimary : Qt.rgba(1, 1, 1, 0.06)
    border.width: isActive ? 2 : 1

    scale: typeof blockMouseArea !== "undefined" && blockMouseArea.containsMouse && overviewRoot.draggingFromWorkspace === -1 ? 1.02 : 1.0

    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
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
        id: blockMouseArea
        anchors.fill: parent
        hoverEnabled: true
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
        
        opacity: isExternalMonitor ? 0.4 : 1.0
        Behavior on opacity { NumberAnimation { duration: 250 } }

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
                model: System.HyprlandService.clientsByWorkspace[wsBlock.wsId] || []

                delegate: WindowPreview {
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

    // External Monitor Badge
    Rectangle {
        visible: isExternalMonitor && wsMonitor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: Math.max(40, badgeText.contentWidth + 16)
        height: 20
        radius: 10
        color: Qt.rgba(0, 0, 0, 0.6)
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1
        z: 50 // Keep on top of windows

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: wsMonitor ? wsMonitor.name : ""
            color: Qt.rgba(1, 1, 1, 0.7)
            font.pixelSize: 10
            font.bold: true
        }
    }
}
