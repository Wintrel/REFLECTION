pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root
    color: "transparent"
    WlrLayershell.namespace: "quickshell:regionSelector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    readonly property HyprlandMonitor hyprlandMonitor: Hyprland.monitorFor(screen)
    readonly property real monitorOffsetX: hyprlandMonitor.x
    readonly property real monitorOffsetY: hyprlandMonitor.y
    readonly property real monitorScale: hyprlandMonitor.scale

    property real dragStartX: 0
    property real dragStartY: 0
    property real draggingX: 0
    property real draggingY: 0
    property bool dragging: false

    property real regionX: Math.min(dragStartX, draggingX)
    property real regionY: Math.min(dragStartY, draggingY)
    property real regionWidth: Math.abs(draggingX - dragStartX)
    property real regionHeight: Math.abs(draggingY - dragStartY)

    function dismiss() {
        ScreenshotState.isOpen = false;
    }

    function snip() {
        if (root.regionWidth <= 0 || root.regionHeight <= 0) {
            root.dismiss();
            return;
        }

        const gx = Math.round(root.monitorOffsetX + root.regionX);
        const gy = Math.round(root.monitorOffsetY + root.regionY);
        const gw = Math.round(root.regionWidth);
        const gh = Math.round(root.regionHeight);
        
        const d = new Date();
        const filename = "Screenshot_" + d.getFullYear() + "-" + (d.getMonth()+1) + "-" + d.getDate() + "_" + d.getHours() + "-" + d.getMinutes() + "-" + d.getSeconds() + ".png";
        const filepath = `~/Pictures/Screenshots/${filename}`;

        Quickshell.execDetached([
            "bash", "-c", 
            `sleep 0.2 && mkdir -p ~/Pictures/Screenshots && grim -g "${gx},${gy} ${gw}x${gh}" ${filepath} && wl-copy < ${filepath} && notify-send "Screenshot Saved" "Copied to clipboard and saved to Pictures" -i ${filepath} -a "REFLECTION"`
        ]);

        root.dismiss();
    }

    ScreencopyView {
        anchors.fill: parent
        live: false
        captureSource: root.screen
        focus: true

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                root.dismiss();
            }
        }
    }

    // Dim overlay cutouts
    Rectangle {
        color: "#99000000" // 60% black
        x: 0; y: 0; width: root.width; height: root.dragging ? root.regionY : root.height
    }
    Rectangle {
        color: "#99000000"
        x: 0; y: root.dragging ? root.regionY + root.regionHeight : root.height
        width: root.width; height: root.height - y
    }
    Rectangle {
        color: "#99000000"
        x: 0; y: root.regionY
        width: root.regionX; height: root.regionHeight
        visible: root.dragging
    }
    Rectangle {
        color: "#99000000"
        x: root.regionX + root.regionWidth; y: root.regionY
        width: root.width - x; height: root.regionHeight
        visible: root.dragging
    }

    // Selection box
    Rectangle {
        visible: root.dragging
        x: root.regionX
        y: root.regionY
        width: root.regionWidth
        height: root.regionHeight
        color: "#1Affffff" // faint fill
        border.color: "#710cee" // Reflection Purple
        border.width: 2
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CrossCursor

        onPressed: (mouse) => {
            root.dragStartX = mouse.x;
            root.dragStartY = mouse.y;
            root.draggingX = mouse.x;
            root.draggingY = mouse.y;
            root.dragging = true;
        }
        onPositionChanged: (mouse) => {
            if (root.dragging) {
                root.draggingX = mouse.x;
                root.draggingY = mouse.y;
            }
        }
        onReleased: (mouse) => {
            if (root.dragging) {
                root.snip();
            } else {
                root.dismiss();
            }
        }
    }
}
