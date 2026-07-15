import sys

file_path = "/home/fuyumi/.config/quickshell/reflection/ui/panels/dynamic_island/components/FilePicker.qml"
with open(file_path, "r") as f:
    lines = f.readlines()

start_idx = -1
end_idx = -1

for i, line in enumerate(lines):
    if "// 2. MAIN WORKSPACE" in line:
        start_idx = i
    if "// 3. FOOTER ACTIONS" in line:
        end_idx = i
        break

if start_idx != -1 and end_idx != -1:
    new_content = """            // 1.5. PLACES SHORTCUTS
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
                                        visible: !model.isDir && root.filterMode !== "images"
                                        anchors.centerIn: parent
                                        text: "insert_drive_file"
                                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                        font.pixelSize: 64
                                        color: Qt.rgba(255, 255, 255, 0.4)
                                    }

                                    // Image thumbnail
                                    Image {
                                        visible: !model.isDir && root.filterMode === "images"
                                        anchors.fill: parent
                                        source: (!model.isDir && root.filterMode === "images") ? "file://" + model.path : ""
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

"""
    lines[start_idx:end_idx] = [new_content]
    with open(file_path, "w") as f:
        f.writelines(lines)
    print("Successfully replaced MAIN WORKSPACE.")
else:
    print(f"Error finding indices: start_idx={start_idx}, end_idx={end_idx}")

