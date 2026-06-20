import QtQuick
import Quickshell
import Quickshell.Io

PanelWindow {
    id: win
    mask: Region {
        items: [rect1, rect2]
    }
    Rectangle { id: rect1; width: 100; height: 100 }
    Rectangle { id: rect2; width: 100; height: 100; y: 200 }
}
