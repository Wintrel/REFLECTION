import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../core/services/system" // Import AccountService.
import "../../../../core/state" as State

Item {
    id: root
    anchors.fill: parent

    property var theme
    property int islandState
    property bool isActive: islandState === State.IslandState.filePicker
    property string title: State.GlobalStates.filePickerTitle
    property string filterMode: State.GlobalStates.filePickerFilterMode
    property string currentPath: ""
    property string selectedFile: ""
    property var callback: State.GlobalStates.filePickerCallback

    visible: opacity > 0
    opacity: isActive ? 1 : 0
    scale: isActive ? 1.0 : 0.95
    layer.enabled: true
    Behavior on opacity { 
        NumberAnimation { 
            duration: root.isActive ? (theme ? theme.durationContentIn : 220) : (theme ? theme.durationContentOut : 120)
            easing.type: root.isActive ? Easing.OutQuad : Easing.InQuad 
        } 
    }
    Behavior on scale {
        NumberAnimation {
            duration: theme ? theme.durationMorph : 360
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: startTimer
        interval: 10
        onTriggered: procLister.running = true
    }

    onIsActiveChanged: {
        if (isActive) {
            if (currentPath === "") {
                currentPath = AccountService.homeDir || "/home/" + (Quickshell.env("USER") || "fuyumi");
            } else {
                procLister.running = false;
                startTimer.restart();
            }
            selectedFile = "";
        }
    }

    onCurrentPathChanged: {
        if (isActive && currentPath !== "") {
            procLister.running = false;
            startTimer.restart();
        }
    }

    // ListModel to store parsed directory contents
    ListModel {
        id: fileModel
    }

    // Process to run the python directory lister
    Process {
        id: procLister
        command: ["/home/fuyumi/.config/quickshell/reflection/scripts/settings/dir_lister.py", root.currentPath, root.filterMode]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var res = JSON.parse(data.trim());
                    if (res.error) {
                        console.log("dir_lister error:", res.error);
                    } else {
                        root.currentPath = res.path;
                        fileModel.clear();
                        for (var i = 0; i < res.items.length; i++) {
                            fileModel.append(res.items[i]);
                        }
                    }
                } catch(e) {
                    console.log("Failed to parse dir_lister JSON:", e);
                }
            }
        }
    }

    // Black translucent background covering the entire card area
    Rectangle {
        anchors.fill: parent
        color: root.theme ? root.theme.bgInner : "#111"
        radius: 12
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.08)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // 1. HEADER (Title, Breadcrumbs, and Controls)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Back / Up Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 6
                    color: maBack.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.03)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.06)

                    Text {
                        anchors.centerIn: parent
                        text: "arrow_upward"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: "#FFF"
                    }

                    MouseArea {
                        id: maBack
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = root.currentPath.split("/");
                            if (p.length > 1) {
                                p.pop();
                                var newPath = p.join("/") || "/";
                                if (newPath !== root.currentPath) {
                                    root.currentPath = newPath;
                                }
                            }
                        }
                    }
                }

                // Title and Breadcrumbs container
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.title
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#FFF"
                    }

                    // Breadcrumbs Flow Row
                    RowLayout {
                        spacing: 2
                        
                        Text {
                            text: "computer"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 14
                            color: Qt.rgba(255, 255, 255, 0.4)
                        }

                        Repeater {
                            model: {
                                var parts = root.currentPath.split("/");
                                var list = [];
                                var currentBuild = "";
                                for (var i = 0; i < parts.length; i++) {
                                    var part = parts[i];
                                    if (i === 0 && part === "") continue;
                                    currentBuild += "/" + part;
                                    list.push({ name: part === "" ? "Root" : part, path: currentBuild });
                                }
                                return list;
                            }
                            delegate: RowLayout {
                                spacing: 2
                                Text {
                                    text: "/"
                                    font.family: "Inter"
                                    font.pixelSize: 11
                                    color: Qt.rgba(255, 255, 255, 0.3)
                                }
                                Text {
                                    text: modelData.name
                                    font.family: "Inter"
                                    font.pixelSize: 11
                                    color: modelData.path === root.currentPath ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.rgba(255, 255, 255, 0.6)
                                    font.weight: modelData.path === root.currentPath ? Font.Medium : Font.Normal

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.currentPath = modelData.path;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Close Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: maClose.containsMouse ? Qt.rgba(255, 68, 68, 0.1) : Qt.rgba(255, 255, 255, 0.03)
                    border.width: 1
                    border.color: maClose.containsMouse ? Qt.rgba(255, 68, 68, 0.2) : Qt.rgba(255, 255, 255, 0.06)

                    Text {
                        anchors.centerIn: parent
                        text: "close"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 16
                        color: maClose.containsMouse ? "#ff4444" : "#FFF"
                    }

                    MouseArea {
                        id: maClose
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            State.GlobalStates.closeFilePicker();
                        }
                    }
                }
            }

            // 1.5. PLACES SHORTCUTS
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "PLACES"
                    font.family: "Inter"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: Qt.rgba(255, 255, 255, 0.4)
                    Layout.rightMargin: 8
                }
                
                Repeater {
                    model: [
                        { name: "Home", icon: "home", path: AccountService.homeDir },
                        { name: "Pictures", icon: "image", path: AccountService.homeDir + "/Pictures" },
                        { name: "Downloads", icon: "download", path: AccountService.homeDir + "/Downloads" },
                        { name: "Documents", icon: "description", path: AccountService.homeDir + "/Documents" }
                    ]

                    delegate: Rectangle {
                        implicitHeight: 28
                        implicitWidth: placeRow.implicitWidth + 24
                        radius: 14
                        color: root.currentPath === modelData.path ? Qt.rgba(255, 255, 255, 0.1) : (maShort.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                        border.width: 1
                        border.color: root.currentPath === modelData.path ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.rgba(255, 255, 255, 0.1)

                        RowLayout {
                            id: placeRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: modelData.icon
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 14
                                color: root.currentPath === modelData.path ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.rgba(255, 255, 255, 0.7)
                            }

                            Text {
                                text: modelData.name
                                font.family: "Inter"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: root.currentPath === modelData.path ? "#FFF" : Qt.rgba(255, 255, 255, 0.8)
                            }
                        }

                        MouseArea {
                            id: maShort
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.currentPath = modelData.path;
                            }
                        }
                    }
                }
                
                Item { Layout.fillWidth: true } // spacer
            }

            // 2. MAIN WORKSPACE (Grid Explorer Only)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollView {
                    anchors.fill: parent
                    clip: true
                    
                    // Added a subtle background for the grid area to make it distinct
                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0.2)
                        radius: 8
                        border.width: 1
                        border.color: Qt.rgba(255, 255, 255, 0.03)
                    }

                    GridView {
                        id: gridView
                        anchors.fill: parent
                        anchors.margins: 16
                        model: fileModel
                        cellWidth: 154
                        cellHeight: 168
                        clip: true

                        delegate: Rectangle {
                            width: 142
                            height: 156
                            radius: 12
                            color: root.selectedFile === model.path ? Qt.rgba(255, 255, 255, 0.08) : (maCell.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : "transparent")
                            border.width: 1
                            border.color: root.selectedFile === model.path ? (root.theme ? root.theme.accentPrimary : "#AAA") : "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                readonly property bool isImg: {
                                    if (model.isDir) return false;
                                    var p = model.path.toLowerCase();
                                    return p.endsWith(".png") || p.endsWith(".jpg") || p.endsWith(".jpeg") || p.endsWith(".webp") || p.endsWith(".gif");
                                }

                                // Thumbnail or Folder icon
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    // Folder Icon
                                    Text {
                                        visible: model.isDir
                                        anchors.centerIn: parent
                                        text: "folder"
                                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                        font.pixelSize: 64
                                        color: root.theme ? root.theme.accentPrimary : "#4b96ff"
                                    }

                                    // File Icon (if not an image)
                                    Text {
                                        visible: !model.isDir && (!parent.parent.isImg || root.filterMode === "folders")
                                        anchors.centerIn: parent
                                        text: "insert_drive_file"
                                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                        font.pixelSize: 64
                                        color: Qt.rgba(255, 255, 255, 0.4)
                                    }

                                    // Image thumbnail
                                    Image {
                                        visible: parent.parent.isImg && root.filterMode !== "folders"
                                        anchors.fill: parent
                                        source: visible ? "file://" + model.path : ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        clip: true
                                        
                                        // Smooth rounded mask for thumbnails
                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: Rectangle {
                                                width: 126
                                                height: 110
                                                radius: 8
                                            }
                                        }
                                    }
                                }

                                // Item Label Name
                                Text {
                                    text: model.name
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    font.weight: root.selectedFile === model.path ? Font.Medium : Font.Normal
                                    color: root.selectedFile === model.path ? "#FFF" : Qt.rgba(255, 255, 255, 0.8)
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideMiddle
                                }
                            }

                            MouseArea {
                                id: maCell
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (model.isDir) {
                                        root.currentPath = model.path;
                                    } else {
                                        root.selectedFile = model.path;
                                    }
                                }
                                onDoubleClicked: {
                                    if (!model.isDir) {
                                        root.selectedFile = model.path;
                                        if (root.callback) root.callback(root.selectedFile);
                                        State.GlobalStates.closeFilePicker();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 3. FOOTER ACTIONS
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: root.selectedFile !== "" ? "Selected: " + root.selectedFile : "No file selected"
                    font.family: "Inter"
                    font.pixelSize: 11
                    color: root.selectedFile !== "" ? Qt.rgba(255, 255, 255, 0.6) : Qt.rgba(255, 255, 255, 0.3)
                    Layout.fillWidth: true
                    elide: Text.ElideLeft
                }

                // Cancel Button
                Rectangle {
                    width: 70
                    height: 32
                    radius: 6
                    color: maCancelBtn.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.03)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.06)

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: "#FFF"
                    }

                    MouseArea {
                        id: maCancelBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            State.GlobalStates.closeFilePicker();
                        }
                    }
                }

                // Select Button
                Rectangle {
                    width: 70
                    height: 32
                    radius: 6
                    color: root.selectedFile !== "" ? (maSelectBtn.containsMouse ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.alpha(root.theme ? root.theme.accentPrimary : "#AAA", 0.8)) : Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: root.selectedFile !== "" ? "transparent" : Qt.rgba(255, 255, 255, 0.04)

                    Text {
                        anchors.centerIn: parent
                        text: "Select"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: root.selectedFile !== "" ? "#000" : Qt.rgba(255, 255, 255, 0.3)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: maSelectBtn
                        anchors.fill: parent
                        enabled: root.selectedFile !== ""
                        hoverEnabled: true
                        cursorShape: root.selectedFile !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (root.callback) {
                                root.callback(root.selectedFile);
                            }
                            State.GlobalStates.closeFilePicker();
                        }
                    }
                }
            }
        }
    }
}
