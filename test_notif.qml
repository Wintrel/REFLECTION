import QtQuick
import Quickshell
import Quickshell.Services.Notifications

ShellRoot {
    NotificationServer {
        id: notifServer
    }
    Component.onCompleted: {
        console.log("NotificationServer properties: ")
        for (var prop in notifServer) {
            console.log(prop + " : " + typeof notifServer[prop])
        }
    }
}
