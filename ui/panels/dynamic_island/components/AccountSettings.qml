import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../core/services/system"

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    property var commonGroups: [
        { name: "wheel", label: "Administrators", desc: "Allows administrative actions via sudo/pkexec", icon: "security" },
        { name: "docker", label: "Docker Engine", desc: "Allows container management without sudo", icon: "layers" },
        { name: "video", label: "Video Hardware", desc: "GPU, webcam, and direct framebuffer access", icon: "videocam" },
        { name: "audio", label: "Audio Hardware", desc: "Direct access to sound card and MIDI hardware", icon: "volume_up" },
        { name: "input", label: "Input Devices", desc: "Access raw mouse, keyboard, and controller devices", icon: "keyboard" },
        { name: "i2c", label: "System Sensors", desc: "Hardware monitor sensors and backlight control", icon: "thermostat" },
        { name: "storage", label: "Device Storage", desc: "Direct mounting of external drives/filesystems", icon: "usb" }
    ]
    
    property int passStrength: {
        var pass = passInput.text;
        if (pass.length === 0) return 0;
        var score = 0;
        if (pass.length >= 8) score += 1;
        if (/[A-Z]/.test(pass)) score += 1;
        if (/[a-z]/.test(pass)) score += 1;
        if (/[0-9]/.test(pass)) score += 1;
        if (/[^A-Za-z0-9]/.test(pass)) score += 1;
        return score; // 0 to 5
    }
    
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 32
            
            // 1. Unified Profile Card
            Rectangle {
                Layout.fillWidth: true
                // implicitHeight = banner height + avatar margin + details height + top margin + bottom padding
                implicitHeight: 140 + 60 + detailsColumn.implicitHeight + 40
                radius: 12
                color: Qt.rgba(255, 255, 255, 0.03)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.05)
                
                // Banner Area
                Item {
                    id: bannerArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 1
                    height: 140
                    
                    Item {
                        id: bannerMaskItem
                        anchors.fill: parent
                        Rectangle {
                            anchors.fill: parent
                            radius: 11
                            color: "black"
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 11
                            color: "black"
                        }
                    }
                    
                    ShaderEffectSource {
                        id: bannerMask
                        sourceItem: bannerMaskItem
                        hideSource: true
                    }
                    
                    Item {
                        id: bannerContent
                        anchors.fill: parent
                        
                        Image {
                            id: bannerImg
                            anchors.fill: parent
                            source: AccountService.bannerPicture
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: AccountService.bannerPicture !== ""
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "add_photo_alternate"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 32
                            color: root.theme ? root.theme.textSub : "#888"
                            visible: AccountService.bannerPicture === ""
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(0, 0, 0, 0.5)
                            opacity: maBanner.containsMouse ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Change Banner"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: "#FFF"
                            }
                        }
                    }
                    
                    ShaderEffectSource {
                        id: bannerSource
                        sourceItem: bannerContent
                        hideSource: true
                    }
                    
                    OpacityMask {
                        anchors.fill: parent
                        source: bannerSource
                        maskSource: bannerMask
                    }
                    
                    MouseArea {
                        id: maBanner
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
                            p.command = ["zenity", "--file-selection", "--title=Select Banner Picture"];
                            p.stdout = Qt.createQmlObject('import Quickshell.Io; SplitParser { }', p);
                            p.stdout.read.connect(function(data) {
                                var file = data.trim();
                                if (file.length > 0) {
                                    bannerCropper.imageSource = "file://" + file;
                                }
                            });
                            p.exited.connect(function() { p.destroy(); });
                            p.running = true;
                        }
                    }
                }
                
                // Divider line connecting banner to card body
                Rectangle {
                    anchors.top: bannerArea.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.05)
                }

                // Avatar Container
                Rectangle {
                    id: avatarContainer
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.top: bannerArea.bottom
                    anchors.topMargin: -40
                    width: 100
                    height: 100
                    radius: 50
                    color: root.theme ? root.theme.bgBase : "#111" // Match shell background to look like a cutout
                    border.width: 4
                    border.color: root.theme ? root.theme.bgBase : "#111"
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Qt.rgba(255, 255, 255, 0.05)
                        clip: true
                        
                        Image {
                            id: avatarImg
                            anchors.fill: parent
                            source: AccountService.profilePicture
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }
                        
                        Rectangle {
                            id: avatarMask
                            anchors.fill: parent
                            radius: width / 2
                            visible: false
                        }
                        
                        OpacityMask {
                            anchors.fill: parent
                            source: avatarImg
                            maskSource: avatarMask
                            visible: avatarImg.source.toString() !== ""
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "person"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 32
                            color: root.theme ? root.theme.textMain : "#FFF"
                            visible: avatarImg.source.toString() === ""
                        }
                        
                        // Avatar Hover Overlay
                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Qt.rgba(0, 0, 0, 0.5)
                            opacity: maAvatar.containsMouse ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "edit"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 24
                                color: "#FFF"
                            }
                        }
                        
                        MouseArea {
                            id: maAvatar
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
                                p.command = ["zenity", "--file-selection", "--title=Select Profile Picture"];
                                p.stdout = Qt.createQmlObject('import Quickshell.Io; SplitParser { }', p);
                                p.stdout.read.connect(function(data) {
                                    var file = data.trim();
                                    if (file.length > 0) {
                                        avatarCropper.imageSource = "file://" + file;
                                    }
                                });
                                p.exited.connect(function() { p.destroy(); });
                                p.running = true;
                            }
                        }
                    }
                }
                
                // System Info (Details)
                ColumnLayout {
                    id: detailsColumn
                    anchors.top: avatarContainer.bottom
                    anchors.topMargin: 24
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 24
                    spacing: 10
                    
                    // Helper layout for each details row (Username, Display Name, Home Dir, Groups)
                    Rectangle {
                        id: userCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maUserRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maUserRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maUserRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: userIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "badge"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: userIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Username"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.username
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: realNameCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maRealNameRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maRealNameRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maRealNameRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: realNameIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "face"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: realNameIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Display Name"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.realName
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: homeCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maHomeRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maHomeRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maHomeRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: homeIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "folder"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: homeIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Home Directory"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.homeDir
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                elide: Text.ElideMiddle
                            }
                        }
                    }

                    Rectangle {
                        id: uidCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maUidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maUidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maUidRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: uidIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "fingerprint"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: uidIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "User ID (UID)"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.uid
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: gidCard
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 8
                        color: maGidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maGidRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maGidRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: gidIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "badge"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            anchors.left: gidIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "Primary Group ID (GID)"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.gid
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Rectangle {
                        id: groupsCard
                        Layout.fillWidth: true
                        implicitHeight: Math.max(52, groupsColumn.implicitHeight + 16)
                        radius: 8
                        color: maGroupsRow.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02)
                        border.width: 1
                        border.color: maGroupsRow.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        MouseArea { id: maGroupsRow; anchors.fill: parent; hoverEnabled: true }
                        
                        Text {
                            id: groupsIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "group"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }
                        
                        Column {
                            id: groupsColumn
                            anchors.left: groupsIcon.right
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            
                            Text {
                                text: "User Groups"
                                color: root.theme ? root.theme.textSub : "#888"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Light
                            }
                            Text {
                                text: AccountService.groups
                                color: root.theme ? root.theme.textMain : "#FFF"
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            // 2. Display Name
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Display Name"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 6
                        color: nameInput.activeFocus ? Qt.rgba(0, 0, 0, 0.4) : Qt.rgba(0, 0, 0, 0.25)
                        border.width: 1
                        border.color: nameInput.activeFocus ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maNameInput.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.06))
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        TextInput {
                            id: nameInput
                            anchors.fill: parent
                            anchors.margins: 12
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.theme ? root.theme.textMain : "#FFF"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            text: AccountService.realName
                        }

                        MouseArea {
                            id: maNameInput
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: nameInput.forceActiveFocus()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 40
                        radius: 6
                        color: maName.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.08)
                        border.width: 1
                        border.color: maName.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.04)
                        opacity: nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0 ? 1.0 : 0.5
                        scale: maName.containsMouse && nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0 ? 1.03 : 1.0
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Apply"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: maName.containsMouse && nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0 ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                        }

                        MouseArea {
                            id: maName
                            anchors.fill: parent
                            enabled: nameInput.text !== AccountService.realName && nameInput.text.trim().length > 0
                            hoverEnabled: enabled
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                AccountService.setRealName(nameInput.text);
                            }
                        }
                    }
                }
            }

            // 3. Password
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Password"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "You will be prompted to authenticate with your old password."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 6
                        color: passInput.activeFocus ? Qt.rgba(0, 0, 0, 0.4) : Qt.rgba(0, 0, 0, 0.25)
                        border.width: 1
                        border.color: passInput.activeFocus ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maPassInput.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.06))
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        TextInput {
                            id: passInput
                            anchors.left: parent.left
                            anchors.right: eyeButton.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 12
                            anchors.rightMargin: 4
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.theme ? root.theme.textMain : "#FFF"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                        }

                        MouseArea {
                            id: maPassInput
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: passInput.forceActiveFocus()
                        }

                        Text {
                            id: eyeButton
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: passInput.echoMode === TextInput.Password ? "visibility" : "visibility_off"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: maEye.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#888")
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: maEye
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    passInput.echoMode = (passInput.echoMode === TextInput.Password) ? TextInput.Normal : TextInput.Password;
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 40
                        radius: 6
                        color: maPass.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.1)
                        border.width: 1
                        border.color: maPass.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.2)
                        opacity: passInput.text.length > 0 ? 1.0 : 0.5
                        scale: maPass.containsMouse && passInput.text.length > 0 ? 1.03 : 1.0
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Change"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: maPass.containsMouse && passInput.text.length > 0 ? "#FFF" : "#ff4444"
                        }

                        MouseArea {
                            id: maPass
                            anchors.fill: parent
                            hoverEnabled: passInput.text.length > 0
                            cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (passInput.text.length > 0) {
                                    AccountService.setPassword(passInput.text);
                                    passInput.text = ""; // clear after submitting
                                }
                            }
                        }
                    }
                }

                // Password strength bar indicators
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: passInput.text.length > 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Repeater {
                            model: 5
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                radius: 2
                                color: {
                                    if (index < root.passStrength) {
                                        if (root.passStrength <= 2) return "#ff4444"; // Weak - Red
                                        if (root.passStrength <= 4) return "#ffbb33"; // Medium - Orange
                                        return "#00C851"; // Strong - Green
                                    } else {
                                        return Qt.rgba(255, 255, 255, 0.1);
                                    }
                                }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    Text {
                        text: {
                            if (root.passStrength === 0) return "";
                            if (root.passStrength <= 2) return "Weak password";
                            if (root.passStrength <= 4) return "Moderate password";
                            return "Strong password";
                        }
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: {
                            if (root.passStrength <= 2) return "#ff4444";
                            if (root.passStrength <= 4) return "#ffbb33";
                            return "#00C851";
                        }
                    }
                }
            }

            // 4. Default Shell Selector
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Default Login Shell"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "Select your default shell. Changing this requires authentication."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Repeater {
                        model: AccountService.availableShells
                        delegate: Rectangle {
                            width: 140
                            height: 48
                            radius: 8
                            color: isCurrent ? Qt.rgba(255, 255, 255, 0.08) : (maShell.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : Qt.rgba(255, 255, 255, 0.02))
                            border.width: 1
                            border.color: isCurrent ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maShell.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(255, 255, 255, 0.04))
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            scale: maShell.containsMouse ? 1.03 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            readonly property string shellPath: modelData
                            readonly property bool isCurrent: {
                                var p1 = shellPath.split("/").pop();
                                var p2 = AccountService.loginShell.split("/").pop();
                                return p1 === p2;
                            }

                            MouseArea {
                                id: maShell
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    AccountService.setShell(shellPath);
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: isCurrent ? "radio_button_checked" : "radio_button_unchecked"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 16
                                    color: isCurrent ? (root.theme ? root.theme.accentPrimary : "#AAA") : (root.theme ? root.theme.textSub : "#888")
                                }

                                Text {
                                    text: {
                                        var p = shellPath.split("/");
                                        return p[p.length - 1];
                                    }
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    font.weight: isCurrent ? Font.Medium : Font.Normal
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            // 5. Storage Quota
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Home Storage Quota"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 80
                    radius: 8
                    color: Qt.rgba(255, 255, 255, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.04)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: "storage"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 28
                            color: root.theme ? root.theme.accentPrimary : "#AAA"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Home Partition (" + AccountService.homeDir + ")"
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: AccountService.storageUsage.used + " / " + AccountService.storageUsage.size + " (" + AccountService.storageUsage.percent + "% used)"
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    color: root.theme ? root.theme.textSub : "#888"
                                }
                            }

                            // Progress Bar Track
                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: Qt.rgba(255, 255, 255, 0.08)

                                // Progress Fill
                                Rectangle {
                                    width: parent.width * (AccountService.storageUsage.percent / 100.0)
                                    height: parent.height
                                    radius: parent.radius
                                    color: {
                                        var pct = AccountService.storageUsage.percent;
                                        if (pct > 85) return "#ff4444";
                                        if (pct > 65) return "#ffbb33";
                                        return root.theme ? root.theme.accentPrimary : "#C0C0D0";
                                    }
                                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }
                    }
                }
            }

            // 6. Group Membership
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "System Group Memberships"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "Manage access to hardware, containers, and administration. Group changes require authentication and system relog to apply."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.commonGroups
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 64
                            radius: 8
                            color: isMember ? Qt.rgba(255, 255, 255, 0.04) : (maGroupCard.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : Qt.rgba(255, 255, 255, 0.015))
                            border.width: 1
                            border.color: isMember ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maGroupCard.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04))
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            scale: maGroupCard.containsMouse ? 1.01 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            readonly property string gName: modelData.name
                            readonly property bool isMember: AccountService.userGroupsList.indexOf(gName) !== -1

                            MouseArea {
                                id: maGroupCard
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    AccountService.toggleGroupMembership(gName, !isMember);
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 16

                                Text {
                                    text: modelData.icon
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 22
                                    color: isMember ? (root.theme ? root.theme.accentPrimary : "#AAA") : (root.theme ? root.theme.textSub : "#888")
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: modelData.label + " (" + gName + ")"
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: root.theme ? root.theme.textMain : "#FFF"
                                    }
                                    Text {
                                        text: modelData.desc
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: root.theme ? root.theme.textSub : "#888"
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: isMember ? "check_circle" : "add_circle_outline"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 20
                                    color: isMember ? "#4ADE80" : (root.theme ? root.theme.textSub : "#888")
                                }
                            }
                        }
                    }
                }
            }

            // 7. SSH Public Keys
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "SSH Public Keys"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "Public keys in ~/.ssh directory. Copy them to add to your remote profiles (e.g., GitHub, GitLab)."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: AccountService.sshKeys.length > 0

                    Repeater {
                        model: AccountService.sshKeys
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 56
                            radius: 8
                            color: Qt.rgba(255, 255, 255, 0.02)
                            border.width: 1
                            border.color: Qt.rgba(255, 255, 255, 0.04)

                            property bool justCopied: false

                            Timer {
                                id: copyTimer
                                interval: 2000
                                onTriggered: justCopied = false
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 16

                                Text {
                                    text: "key"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 20
                                    color: root.theme ? root.theme.accentPrimary : "#AAA"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: modelData.name
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: root.theme ? root.theme.textMain : "#FFF"
                                    }
                                    Text {
                                        text: modelData.type + (modelData.comment ? " • " + modelData.comment : "")
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: root.theme ? root.theme.textSub : "#888"
                                        elide: Text.ElideRight
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: justCopied ? 85 : 70
                                    Layout.preferredHeight: 32
                                    radius: 6
                                    color: justCopied ? "#00C851" : (maCopy.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.08))
                                    border.width: 1
                                    border.color: justCopied ? "#00C851" : (maCopy.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.04))
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: justCopied ? "Copied!" : "Copy"
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: justCopied || maCopy.containsMouse ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                                    }

                                    MouseArea {
                                        id: maCopy
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            AccountService.copyToClipboard(modelData.content);
                                            justCopied = true;
                                            copyTimer.restart();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 8
                    color: Qt.rgba(255, 255, 255, 0.015)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.04)
                    visible: AccountService.sshKeys.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: "No SSH public keys (*.pub) found in ~/.ssh/"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                }
            }

            // 8. Active Login Sessions
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Active Login Sessions"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: "Current logged-in system sessions. You can terminate remote or background console sessions directly."
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: root.theme ? root.theme.textSub : "#888"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: AccountService.activeSessions
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 64
                            radius: 8
                            color: isCurrentSession ? Qt.rgba(255, 255, 255, 0.04) : (maSessionCard.containsMouse ? Qt.rgba(255, 255, 255, 0.03) : Qt.rgba(255, 255, 255, 0.015))
                            border.width: 1
                            border.color: isCurrentSession ? (root.theme ? root.theme.accentPrimary : "#AAA") : (maSessionCard.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.04))
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            readonly property string sId: modelData.id
                            readonly property string sType: modelData.type
                            readonly property string sTty: modelData.tty
                            readonly property string sDesktop: modelData.desktop
                            readonly property bool isCurrentSession: Quickshell.env("XDG_SESSION_ID") === sId

                            MouseArea {
                                id: maSessionCard
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: isCurrentSession ? Qt.ArrowCursor : Qt.PointingHandCursor
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 16

                                Text {
                                    text: sType === "wayland" || sType === "x11" ? "desktop_windows" : "terminal"
                                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                    font.pixelSize: 22
                                    color: isCurrentSession ? (root.theme ? root.theme.accentPrimary : "#AAA") : (root.theme ? root.theme.textSub : "#888")
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: {
                                            var desc = "";
                                            if (sDesktop) desc += sDesktop + " (";
                                            desc += sType.charAt(0).toUpperCase() + sType.slice(1);
                                            if (sDesktop) desc += ")";
                                            if (sTty) desc += " on " + sTty;
                                            return desc;
                                        }
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: root.theme ? root.theme.textMain : "#FFF"
                                    }
                                    Text {
                                        text: "Active for " + modelData.duration + (modelData.service ? " • via " + modelData.service : "")
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: root.theme ? root.theme.textSub : "#888"
                                        elide: Text.ElideRight
                                    }
                                }

                                // Status Badge / Terminate Button
                                Item {
                                    Layout.preferredWidth: badgeContainer.implicitWidth
                                    Layout.preferredHeight: 32

                                    RowLayout {
                                        id: badgeContainer
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8

                                        // Current badge
                                        Rectangle {
                                            visible: isCurrentSession
                                            height: 24
                                            width: 75
                                            radius: 12
                                            color: Qt.rgba(74, 222, 128, 0.15)
                                            border.width: 1
                                            border.color: "#4ADE80"
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Current"
                                                font.family: "Inter"
                                                font.pixelSize: 11
                                                font.weight: Font.Bold
                                                color: "#4ADE80"
                                            }
                                        }

                                        // Terminate Button
                                        Rectangle {
                                            visible: !isCurrentSession
                                            height: 32
                                            width: 85
                                            radius: 6
                                            color: maTerm.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.1)
                                            border.width: 1
                                            border.color: maTerm.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.2)
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                            Behavior on border.color { ColorAnimation { duration: 150 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Terminate"
                                                font.family: "Inter"
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                color: maTerm.containsMouse ? "#FFF" : "#ff4444"
                                            }

                                            MouseArea {
                                                id: maTerm
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    AccountService.terminateSession(sId);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Live Cropper Overlays
    ProfilePictureCropper {
        id: avatarCropper
        anchors.fill: parent
        theme: root.theme
        onCropped: {
            AccountService.refreshInfo();
        }
    }

    BannerPictureCropper {
        id: bannerCropper
        anchors.fill: parent
        theme: root.theme
        onCropped: {
            AccountService.refreshInfo();
        }
    }
}
