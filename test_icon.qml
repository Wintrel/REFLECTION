import QtQuick
import Quickshell

ShellRoot {
    Window {
        width: 100
        height: 100
        visible: true
        Image {
            anchors.fill: parent
            source: "image://invalid_prov/discord"
            onStatusChanged: if (status === Image.Error) console.log("Error loading image")
        }
    }
}
