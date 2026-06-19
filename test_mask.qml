import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        id: pw
        color: "transparent"
        mask: Region {
            item: rect
        }
        Rectangle { id: rect; width: 100; height: 100; color: "red" }
    }
}
