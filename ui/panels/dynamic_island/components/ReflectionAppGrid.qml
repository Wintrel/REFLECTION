import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../core/state" as State
import "../../../../core/services/system"

Item {
    id: root
    
    property var theme: null
    property string query: State.ReflectionState.searchQuery
    property string activeCategory: "All"
    
    // Keyboard navigation
    property int selectedIndex: 0

    onActiveCategoryChanged: filterApps(query)
    onQueryChanged: {
        selectedIndex = 0;
        filterApps(query);
    }
    
    function moveUp() {
        if (appModel.count > 0) {
            selectedIndex = Math.max(0, selectedIndex - 1);
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }
    }
    
    function moveDown() {
        if (appModel.count > 0) {
            selectedIndex = Math.min(appModel.count - 1, selectedIndex + 1);
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }
    }
    
    function launchSelected() {
        if (appModel.count === 0 || selectedIndex < 0 || selectedIndex >= appModel.count) return;
        
        var item = appModel.get(selectedIndex);
        if (!item) return;
        
        if (item.isRunning) {
            var className = item.appId.replace(".desktop", "");
            var p = Qt.createQmlObject(
                'import Quickshell.Io; Process { command: ["hyprctl", "dispatch", "focuswindow", "' + className + '"] }',
                root
            );
            p.running = true;
        } else {
            if (item.appRef && typeof item.appRef.execute === "function") {
                item.appRef.execute();
            }
        }
        State.ReflectionState.close();
    }
    
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
    
    function filterApps(q) {
        var lowerQuery = q.toLowerCase();
        appModel.clear();
        
        var seenIds = {};
        var matched = [];
        var runningClients = HyprlandService.clients || [];
        
        for (var i = 0; i < root.allApps.length; i++) {
            var app = root.allApps[i];
            if (seenIds[app.id]) continue;
            seenIds[app.id] = true;
            
            if (root.activeCategory !== "All") {
                var cats = app.categories || [];
                var c = root.activeCategory;
                var matchCat = false;
                if (c === "Internet" && cats.find(x => x.indexOf("Network")!==-1 || x.indexOf("WebBrowser")!==-1)) matchCat = true;
                else if (c === "Games" && cats.find(x => x.indexOf("Game")!==-1)) matchCat = true;
                else if (c === "Development" && cats.find(x => x.indexOf("Development")!==-1)) matchCat = true;
                else if (c === "Office" && cats.find(x => x.indexOf("Office")!==-1)) matchCat = true;
                else if (c === "System" && cats.find(x => x.indexOf("System")!==-1 || x.indexOf("Settings")!==-1 || x.indexOf("Utility")!==-1)) matchCat = true;
                
                if (!matchCat) continue;
            }
            
            if (q === "" || app.name.toLowerCase().indexOf(lowerQuery) !== -1 || (app.genericName && app.genericName.toLowerCase().indexOf(lowerQuery) !== -1)) {
                
                // Running App Awareness Check
                var isRunning = false;
                var runningWorkspace = -1;
                for (var k = 0; k < runningClients.length; k++) {
                    var client = runningClients[k];
                    if (client.className && app.id.toLowerCase().indexOf(client.className.toLowerCase()) !== -1) {
                        isRunning = true;
                        runningWorkspace = client.workspaceId;
                        break;
                    }
                }
                
                app.isRunning = isRunning;
                app.runningWorkspace = runningWorkspace;
                matched.push(app);
            }
        }
        
        // Sort alphabetically, but put running apps first!
        matched.sort(function(a, b) {
            if (a.isRunning && !b.isRunning) return -1;
            if (!a.isRunning && b.isRunning) return 1;
            return a.name.localeCompare(b.name);
        });
        
        for (var j = 0; j < matched.length; j++) {
            // Resolve icon path using Quickshell's icon theme resolver
            var iconSource = "";
            var rawIcon = matched[j].icon || "";
            if (rawIcon !== "") {
                // If it's already an absolute path, use file:// prefix
                if (rawIcon.startsWith("/")) {
                    iconSource = "file://" + rawIcon;
                }
                // If it's already a full URI, use as-is
                else if (rawIcon.indexOf("://") !== -1) {
                    iconSource = rawIcon;
                }
                // Otherwise, resolve through Quickshell's icon theme
                else {
                    iconSource = Quickshell.iconPath(rawIcon);
                }
            }
            
            appModel.append({
                "appId": matched[j].id,
                "appName": matched[j].name,
                "appIcon": iconSource,
                "appGenericName": matched[j].genericName || "",
                "appRef": matched[j],
                "isRunning": matched[j].isRunning || false,
                "runningWorkspace": matched[j].runningWorkspace || -1
            });
        }
    }
    
    // Category Pills Row
    Row {
        id: categoryRow
        spacing: 6
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: ["All", "Internet", "Games", "Development", "Office", "System"]
            delegate: Rectangle {
                width: pillText.implicitWidth + 20
                height: 28
                radius: 14
                
                color: {
                    if (root.activeCategory === modelData)
                        return root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.15) : "rgba(255, 153, 0, 0.15)";
                    if (pillMouse.containsMouse)
                        return root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.05) : "rgba(255,255,255,0.05)";
                    return "transparent";
                }
                border.width: root.activeCategory === modelData ? 1 : 0
                border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.4) : "rgba(255, 153, 0, 0.4)"
                
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.width { NumberAnimation { duration: 150 } }
                
                Text {
                    id: pillText
                    text: modelData
                    anchors.centerIn: parent
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    font.weight: root.activeCategory === modelData ? Font.DemiBold : Font.Normal
                    color: root.activeCategory === modelData ? (root.theme ? root.theme.accentPrimary : "#ff9900") : (root.theme ? root.theme.textSub : "#888888")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: pillMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeCategory = modelData
                }
            }
        }
    }
    
    // App List (List-style results)
    ListView {
        id: listView
        anchors.top: categoryRow.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 12
        model: appModel
        clip: true
        spacing: 4
        currentIndex: root.selectedIndex
        highlightFollowsCurrentItem: false
        
        // Empty State
        Item {
            anchors.fill: parent
            visible: listView.count === 0 && root.query.length > 0
            
            Column {
                anchors.centerIn: parent
                spacing: 10
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "search_off"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 40
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.3) : "#40A6ADC8"
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No results for \"" + root.query + "\""
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: root.theme ? Qt.rgba(root.theme.textSub.r, root.theme.textSub.g, root.theme.textSub.b, 0.6) : "#99A6ADC8"
                }
            }
        }
        
        delegate: Item {
            id: delegateRoot
            width: ListView.view.width
            height: 52
            
            property bool isSelected: index === root.selectedIndex
            
            // Staggered fade-in
            opacity: 0
            NumberAnimation on opacity {
                to: 1
                duration: 250
                easing.type: Easing.OutCubic
            }

            Rectangle {
                id: cardBg
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                radius: 12
                color: {
                    if (delegateRoot.isSelected)
                        return root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.12) : "rgba(255, 153, 0, 0.12)";
                    if (mouseArea.containsMouse)
                        return root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.08) : "#14FFFFFF";
                    return "transparent";
                }
                Behavior on color { ColorAnimation { duration: 150 } }
                
                // Selected item left accent (orange for active focus)
                Rectangle {
                    visible: delegateRoot.isSelected && !model.isRunning
                    width: 3
                    height: parent.height - 16
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 1.5
                    color: root.theme ? root.theme.accentPrimary : "#ff9900"
                    opacity: 0.8
                }
                
                // Running app left accent (indigo for identity)
                Rectangle {
                    visible: model.isRunning
                    width: 3
                    height: parent.height - 16
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 1.5
                    color: root.theme ? root.theme.colorNotification : "#710cee"
                    opacity: 0.6
                }
                
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12
                    
                    // App Icon (compact, structured)
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.theme ? Qt.rgba(root.theme.textMain.r, root.theme.textMain.g, root.theme.textMain.b, 0.05) : "#0DFFFFFF"
                        
                        Image {
                            id: appIconImg
                            width: 24
                            height: 24
                            sourceSize.width: 24
                            sourceSize.height: 24
                            anchors.centerIn: parent
                            source: model.appIcon || ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            visible: status === Image.Ready
                        }
                        
                        // Fallback: first letter of app name
                        Text {
                            anchors.centerIn: parent
                            visible: appIconImg.status !== Image.Ready
                            text: model.appName ? model.appName.charAt(0).toUpperCase() : "?"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: root.theme ? root.theme.textSub : "#A6ADC8"
                        }
                    }
                    
                    // Text Content
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 36 - 12 - (wsLabel.visible ? wsLabel.width + 12 : 0) - 28
                        spacing: 2
                        
                        Text {
                            text: model.appName
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: root.theme ? root.theme.textMain : "#FFFFFF"
                            width: parent.width
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: model.appGenericName
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            color: root.theme ? root.theme.textSub : "#A6ADC8"
                            width: parent.width
                            elide: Text.ElideRight
                            visible: text !== ""
                        }
                    }
                    
                    // Running workspace indicator pill
                    Rectangle {
                        id: wsLabel
                        visible: model.isRunning
                        anchors.verticalCenter: parent.verticalCenter
                        width: wsText.implicitWidth + 14
                        height: 22
                        radius: 11
                        color: root.theme ? Qt.rgba(root.theme.colorNotification.r, root.theme.colorNotification.g, root.theme.colorNotification.b, 0.15) : "rgba(113, 12, 238, 0.15)"
                        border.width: 1
                        border.color: root.theme ? Qt.rgba(root.theme.colorNotification.r, root.theme.colorNotification.g, root.theme.colorNotification.b, 0.3) : "rgba(113, 12, 238, 0.3)"
                        
                        Text {
                            id: wsText
                            text: "WS " + model.runningWorkspace
                            anchors.centerIn: parent
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: root.theme ? root.theme.colorNotification : "#710cee"
                        }
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.selectedIndex = index
                    onClicked: {
                        root.selectedIndex = index;
                        root.launchSelected();
                    }
                }
            }
        }
        
        ScrollBar.vertical: ScrollBar {
            id: vbar
            active: true
            contentItem: Rectangle {
                implicitWidth: 3
                radius: 1.5
                color: root.theme ? root.theme.textSub : "#A6ADC8"
                opacity: vbar.active ? 0.4 : 0.0
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
            background: Item {}
        }
    }
}
