import QtQuick
import Quickshell

Item {
    Component.onCompleted: {
        var r = Qt.createQmlObject("import Quickshell; Region {}", this);
        for (var prop in r) {
            console.log(prop);
        }
    }
}
