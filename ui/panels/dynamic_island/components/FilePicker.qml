import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../core/services/system" // Import AccountService
import "../../../../core/state" as State

Item {
    id: root

    property var theme
    property int islandState
    property bool isActive: islandState === 12
    property string title: State.GlobalStates.filePickerTitle
    property string filterMode: State.GlobalStates.filePickerFilterMode
    property string currentPath: ""
    property string selectedFile: ""
    property var callback: State.GlobalStates.filePickerCallback

    visible: isActive
    opacity: isActive ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

    onIsActiveChanged: {
        if (isActive) {
            if (currentPath === "") {
                currentPath = AccountService.homeDir || "/home/" + (Quickshell.env("USER") || "fuyumi");
            } else {
                procLister.running = true;
            }
            selectedFile = "";
        }
    }

    onCurrentPathChanged: {
        if (isActive && currentPath !== "") {
            procLister.running = true;
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
                            if (p.length > 2) {
                                p.pop();
                                root.currentPath = p.join("/");
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

            // 2. MAIN WORKSPACE (Sidebar, Grid Explorer, Details Panel)
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // A. Left Shortcuts Sidebar
                ColumnLayout {
                    Layout.preferredWidth: 140
                    Layout.fillHeight: true
                    spacing: 4

                    Text {
                        text: "PLACES"
                        font.family: "Inter"
                        font.pixelSize: 10
                        font.weight: Font.Light
                        color: Qt.rgba(255, 255, 255, 0.3)
                        Layout.bottomMargin: 4
                    }

                    Repeater {
                        model: [
                            { name: "Home", icon: "home", path: AccountService.homeDir },
                            { name: "Pictures", icon: "image", path: AccountService.homeDir + "/Pictures" },
                            { name: "Downloads", icon: "download", path: AccountService.homeDir + "/Downloads" },
                            { name: "Documents", icon: "description", path: AccountService.homeDir + "/Documents" },
                            { name: "Desktop", icon: "desktop_windows", path: AccountService.homeDir + "/Desktop" }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: 6
                            color: root.currentPath === modelData.path ? Qt.rgba(255, 255, 255, 0.06) : (maShort.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : "transparent")
                            border.width: 1
                            border.color: root.currentPath === modelData.path ? (root.theme ? root.theme.accentPrimary : "#AAA") : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Text {
                                    text: modelData.icon
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 16
                                    color: root.currentPath === modelData.path ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.rgba(255, 255, 255, 0.7)
                                }

                                Text {
                                    text: modelData.name
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    color: root.currentPath === modelData.path ? "#FFF" : Qt.rgba(255, 255, 255, 0.8)
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
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

                    Item { Layout.fillHeight: true } // spacer
                }

                // Divider line
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: Qt.rgba(255, 255, 255, 0.06)
                }

                // B. Middle File Grid Explorer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ScrollView {
                        anchors.fill: parent
                        clip: true

                        GridView {
                            id: gridView
                            anchors.fill: parent
                            model: fileModel
                            cellWidth: 88
                            cellHeight: 96
                            clip: true

                            delegate: Rectangle {
                                width: 80
                                height: 88
                                radius: 8
                                color: root.selectedFile === path ? Qt.rgba(255, 255, 255, 0.08) : (maCell.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : "transparent")
                                border.width: 1
                                border.color: root.selectedFile === path ? (root.theme ? root.theme.accentPrimary : "#AAA") : "transparent"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 4

                                    // Thumbnail or Folder icon
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        // Folder Icon
                                        Text {
                                            visible: isDir
                                            anchors.centerIn: parent
                                            text: "folder"
                                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                            font.pixelSize: 42
                                            color: root.theme ? root.theme.accentPrimary : "#4b96ff"
                                        }

                                        // File Icon (if not an image)
                                        Text {
                                            visible: !isDir && root.filterMode !== "images"
                                            anchors.centerIn: parent
                                            text: "insert_drive_file"
                                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                            font.pixelSize: 42
                                            color: Qt.rgba(255, 255, 255, 0.4)
                                        }

                                        // Image thumbnail
                                        Image {
                                            visible: !isDir
                                            anchors.fill: parent
                                            source: "file://" + path
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            cache: true
                                            clip: true
                                            
                                            // Smooth rounded mask for thumbnails
                                            layer.enabled: true
                                            layer.effect: OpacityMask {
                                                maskSource: Rectangle {
                                                    width: 68
                                                    height: 52
                                                    radius: 4
                                                }
                                            }
                                        }
                                    }

                                    // Item Label Name
                                    Text {
                                        text: name
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: root.selectedFile === path ? "#FFF" : Qt.rgba(255, 255, 255, 0.8)
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
                                        if (isDir) {
                                            root.currentPath = path;
                                        } else {
                                            root.selectedFile = path;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Divider line
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: Qt.rgba(255, 255, 255, 0.06)
                }

                // C. Right Details Panel (Displays details & preview for selected file)
                Rectangle {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    radius: 8
                    color: Qt.rgba(255, 255, 255, 0.015)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.04)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: "PREVIEW"
                            font.family: "Inter"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: Qt.rgba(255, 255, 255, 0.3)
                        }

                        // Placeholder when no file is selected
                        ColumnLayout {
                            visible: root.selectedFile === ""
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 8
                            
                            Item { Layout.fillHeight: true }
                            
                            Text {
                                text: "image"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 48
                                color: Qt.rgba(255, 255, 255, 0.1)
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Select an image"
                                font.family: "Inter"
                                font.pixelSize: 12
                                color: Qt.rgba(255, 255, 255, 0.4)
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Item { Layout.fillHeight: true }
                        }

                        // File details view
                        ColumnLayout {
                            visible: root.selectedFile !== ""
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 8

                            // Large image preview container
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                radius: 6
                                color: "#000"
                                clip: true

                                Image {
                                    id: previewImg
                                    anchors.fill: parent
                                    source: root.selectedFile !== "" ? "file://" + root.selectedFile : ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                            }

                            // File Name
                            Text {
                                text: {
                                    var p = root.selectedFile.split("/");
                                    return p[p.length - 1];
                                }
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#FFF"
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            // File Size
                            Text {
                                text: {
                                    // Search model for matching item size
                                    for (var i = 0; i < fileModel.count; i++) {
                                        var item = fileModel.get(i);
                                        if (item.path === root.selectedFile) {
                                            return "Size: " + item.size;
                                        }
                                    }
                                    return "";
                                }
                                font.family: "Inter"
                                font.pixelSize: 11
                                color: Qt.rgba(255, 255, 255, 0.5)
                                Layout.fillWidth: true
                            }

                            Item { Layout.fillHeight: true }
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
                    color: root.selectedFile !== "" ? (maSelectBtn.containsMouse ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.rgba(root.theme ? root.theme.accentPrimary : "#AAA", 0.8)) : Qt.rgba(255, 255, 255, 0.02)
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
