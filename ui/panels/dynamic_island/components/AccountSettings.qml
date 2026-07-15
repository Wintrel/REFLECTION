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
