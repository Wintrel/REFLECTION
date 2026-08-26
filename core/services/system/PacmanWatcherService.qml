pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool isWatching: watcherProc.running

    Process {
        id: watcherProc
        command: ["python3", "-u", Qt.resolvedUrl("pacman_watcher.py").toString().replace(/^file:\/\//, "")]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line === "START") {
                    ActionProgressService.actionStarted("Package Manager Active...", "system_update", "pacman");
                } else if (line === "STOP") {
                    ActionProgressService.actionFinished("Packages Upgraded", "check", true);
                }
            }
        }
    }
}

