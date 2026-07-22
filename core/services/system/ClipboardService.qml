import QtQuick
import Quickshell
import Quickshell.Io
import "../../state" as State

pragma Singleton
pragma ComponentBehavior: Bound
//
Singleton {
    id: root

    property alias items: itemsModel
    ListModel {
        id: itemsModel
    }

    property var _tempLines: []

    Process {
        id: listProcess
        command: ["sh", "-c", "cliphist list | head -n 50"]
        
        stdout: SplitParser {
            onRead: data => {
                root._tempLines.push(data);
            }
        }
        
        onExited: (exitCode) => {
            if (exitCode === 0) {
                var newItems = [];
                var imageIds = [];
                
                var maxItems = 50;
                var count = Math.min(root._tempLines.length, maxItems);
                
                for (var i = 0; i < count; i++) {
                    var line = root._tempLines[i];
                    if (line.trim() === "") continue;
                    var parts = line.split('\t');
                    if (parts.length >= 2) {
                        var id = parts[0];
                        var text = parts.slice(1).join('\t');
                        var isImage = text.indexOf("[[ binary data") !== -1;
                        var imagePath = "";
                        
                        if (isImage) {
                            text = "Image Data";
                            imagePath = "file:///tmp/cliphist_" + id + ".png";
                            imageIds.push(id);
                        }
                        
                        newItems.push({
                            "clipId": id,
                            "clipText": text,
                            "isImage": isImage,
                            "imagePath": imagePath
                        });
                    }
                }
                
                if (imageIds.length > 0) {
                    var script = "for id in " + imageIds.join(" ") + "; do if [ ! -f /tmp/cliphist_$id.png ]; then cliphist decode $id > /tmp/cliphist_$id.png; fi; done";
                    var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + script + '"]; onExited: destroy() }', root);
                    p.running = true;
                }
                
                itemsModel.clear();
                for (var j = 0; j < newItems.length; j++) {
                    itemsModel.append(newItems[j]);
                }
            }
            root._tempLines = [];
        }
    }

    function refresh() {
        root._tempLines = [];
        listProcess.running = true;
    }

    function copyItem(id) {
        var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "cliphist decode ' + id + ' | wl-copy"]; onExited: destroy() }', root);
        p.running = true;
        State.GlobalStates.clipboardOpen = false;
    }
    
    function deleteItem(id) {
        var cmd = "cliphist list | grep '^" + id + "\t' | cliphist delete";
        var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"]; onExited: { ClipboardService.refresh(); destroy() } }', root);
        p.running = true;
    }

    Connections {
        target: State.GlobalStates
        function onClipboardOpenChanged() {
            if (State.GlobalStates.clipboardOpen) {
                root.refresh();
            }
        }
    }
}
