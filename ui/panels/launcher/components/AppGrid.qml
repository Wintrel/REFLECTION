import QtQuick
import QtQuick.Controls
import Quickshell
import qs.ui.panels.launcher

Item {
    id: root
    
    property var theme: null
    property string query: AppLauncherState.searchQuery
    
    // We will build a ListModel manually to filter
    ListModel {
        id: appModel
    }
    
    // The list of all apps
    property var allApps: []
    property var appsList: Array.from(DesktopEntries.applications.values)
    
    onAppsListChanged: {
        root.allApps = appsList;
        filterApps(root.query);
    }
    
    onQueryChanged: {
        filterApps(query);
    }
    
    function filterApps(q) {
        var lowerQuery = q.toLowerCase();
        appModel.clear();
        
        // Remove duplicates by ID and filter
        var seenIds = {};
        var matched = [];
        
        for (var i = 0; i < root.allApps.length; i++) {
            var app = root.allApps[i];
            if (seenIds[app.id]) continue;
            seenIds[app.id] = true;
            
            if (q === "" || app.name.toLowerCase().indexOf(lowerQuery) !== -1 || (app.genericName && app.genericName.toLowerCase().indexOf(lowerQuery) !== -1)) {
                matched.push(app);
            }
        }
        
        // Sort alphabetically
        matched.sort(function(a, b) {
            return a.name.localeCompare(b.name);
        });
        
        for (var j = 0; j < matched.length; j++) {
            appModel.append({
                "appId": matched[j].id,
                "appName": matched[j].name,
                "appIcon": matched[j].icon,
                "appRef": matched[j]
            });
        }
    }
    
    GridView {
        id: grid
        anchors.fill: parent
        anchors.margins: 10
        model: appModel
        cellWidth: 100
        cellHeight: 120
        clip: true
        
        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight
            
            Rectangle {
                id: bgRect
                anchors.fill: parent
                anchors.margins: 5
                radius: 12
                color: mouseArea.containsMouse ? (root.theme ? Qt.rgba(root.theme.colorNotification.r, root.theme.colorNotification.g, root.theme.colorNotification.b, 0.2) : "rgba(255,255,255,0.1)") : "transparent"
                
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Image {
                        width: 64
                        height: 64
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: {
                            if (model.appIcon && model.appIcon !== "") {
                                if (model.appIcon.indexOf("/") !== -1) return "file://" + model.appIcon;
                                return "image://icon/" + model.appIcon;
                            }
                            return "image://icon/application-x-executable";
                        }
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                    
                    Text {
                        text: model.appName
                        width: grid.cellWidth - 20
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textMain : "#FFFFFF"
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        var app = model.appRef;
                        if (app && typeof app.execute === "function") {
                            app.execute();
                        }
                        AppLauncherState.close();
                    }
                }
            }
        }
        
        ScrollBar.vertical: ScrollBar {
            active: true
        }
    }
}
