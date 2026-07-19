import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../../core/services/system" as System
import "../../../core/state" as State

Item {
    id: windowItem
    required property var modelData
    required property var theme
    required property var overviewRoot
    required property var gridLayoutObj
    required property int wsBlockId
    
    property real mX: 0
    property real mY: 0
    property real mW: 1920
    property real mH: 1080
    property real scaleFactor: 1.0
    
    property string windowAddress: modelData.address

    // Position relative to monitor
    x: Math.max(0, (modelData.at[0] - mX) * scaleFactor)
    y: Math.max(0, (modelData.at[1] - mY) * scaleFactor)
    width: Math.max(12, (modelData.size[0] || 0) * scaleFactor)
    height: Math.max(12, (modelData.size[1] || 0) * scaleFactor)

    scale: (windowDragArea.containsMouse || (typeof closeBtnArea !== "undefined" && closeBtnArea.containsMouse)) && !windowDragArea.drag.active ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    Behavior on x { enabled: !windowDragArea.drag.active; NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    Behavior on y { enabled: !windowDragArea.drag.active; NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }

    z: windowDragArea.drag.active ? 9999 : (modelData.floating ? 2 : 1)
    Drag.active: windowDragArea.drag.active
    Drag.source: windowItem
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    Rectangle {
        id: windowVisual
        anchors.fill: parent
        radius: Math.max(4, 8 * scaleFactor)
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
            captureSource: (overviewRoot.overviewVisible && windowVisual.toplevel) ? windowVisual.toplevel : null
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
            overviewRoot.draggingFromWorkspace = wsBlockId;
            windowItem.Drag.active = true;
        }
        onReleased: {
            var targetWs = overviewRoot.draggingTargetWorkspace;
            var finalWs = targetWs !== -1 ? targetWs : wsBlockId;
            var isDifferentWs = (finalWs !== wsBlockId);

            // Calculate drop percentage relative to the TARGET workspace block
            var targetGroupIndex = finalWs - 1 - overviewRoot.workspaceGroup * overviewRoot.workspacesPerPage;
            var targetRow = Math.floor(targetGroupIndex / overviewRoot.columns);
            var targetCol = targetGroupIndex % overviewRoot.columns;
            var targetBlockX = targetCol * (overviewRoot.wsBlockWidth + overviewRoot.wsSpacing);
            var targetBlockY = targetRow * (overviewRoot.wsBlockHeight + overviewRoot.wsSpacing);
            var targetBlockInRoot = gridLayoutObj.mapToItem(overviewRoot, targetBlockX, targetBlockY);
            
            var topLeftInRoot = windowItem.parent.mapToItem(overviewRoot, windowItem.x, windowItem.y);
            
            var px = (topLeftInRoot.x - targetBlockInRoot.x) / overviewRoot.wsBlockWidth;
            var py = (topLeftInRoot.y - targetBlockInRoot.y) / overviewRoot.wsBlockHeight;
            px = Math.max(0, Math.min(1, px));
            py = Math.max(0, Math.min(1, py));

            windowItem.Drag.active = false;
            overviewRoot.draggingFromWorkspace = -1;

            if (isDifferentWs) {
                // Move it to the new workspace
                overviewRoot.dispatch('hl.dsp.window.move({ workspace = "' + finalWs + '", window = "address:' + windowItem.windowAddress + '", follow = false })');
            }

            if (modelData.floating) {
                // Update floating window exact coordinates
                var screenX = Math.round(px * overviewRoot.monW) + (overviewRoot.primaryMonitor ? overviewRoot.primaryMonitor.x : 0);
                var screenY = Math.round(py * overviewRoot.monH) + (overviewRoot.primaryMonitor ? overviewRoot.primaryMonitor.y : 0);
                overviewRoot.dispatch('hl.dsp.window.move({ x = "' + screenX + '", y = "' + screenY + '", window = "address:' + windowItem.windowAddress + '" })');
            }
            
            // Restore position bindings so the window snaps back
            windowItem.x = Qt.binding(function() { return Math.max(0, (modelData.at[0] - mX) * scaleFactor); });
            windowItem.y = Qt.binding(function() { return Math.max(0, (modelData.at[1] - mY) * scaleFactor); });
        }
        onClicked: (event) => {
            if (event.button === Qt.LeftButton) {
                State.GlobalStates.overviewOpen = false;
                overviewRoot.dispatch('hl.dsp.focus({ window = "address:' + windowItem.windowAddress + '" })');
            } else if (event.button === Qt.MiddleButton) {
                overviewRoot.dispatch('hl.dsp.window.close({ window = "address:' + windowItem.windowAddress + '" })');
            }
        }
    }

    // Close button overlay
    Rectangle {
        id: closeBtn
        width: Math.max(16, 24 * scaleFactor)
        height: width
        radius: width / 2
        color: closeBtnArea.containsMouse ? theme.error : Qt.rgba(0,0,0, 0.6)
        border.color: Qt.rgba(1,1,1, 0.2)
        border.width: 1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4 * scaleFactor
        opacity: windowDragArea.containsMouse || closeBtnArea.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "✕"
            color: "white"
            font.pixelSize: parent.height * 0.5
            font.bold: true
        }

        MouseArea {
            id: closeBtnArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                overviewRoot.dispatch('hl.dsp.window.close({ window = "address:' + windowItem.windowAddress + '" })');
            }
        }
    }
}
