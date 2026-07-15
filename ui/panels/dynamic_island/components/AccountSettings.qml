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
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Username:"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter"; font.pixelSize: 13; Layout.preferredWidth: 100 }
                        Text { text: AccountService.username; color: root.theme ? root.theme.textMain : "#FFF"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Display Name:"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter"; font.pixelSize: 13; Layout.preferredWidth: 100 }
                        Text { text: AccountService.realName; color: root.theme ? root.theme.textMain : "#FFF"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Home Directory:"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter"; font.pixelSize: 13; Layout.preferredWidth: 100 }
                        Text { text: AccountService.homeDir; color: root.theme ? root.theme.textMain : "#FFF"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Groups:"; color: root.theme ? root.theme.textSub : "#888"; font.family: "Inter"; font.pixelSize: 13; Layout.preferredWidth: 100 }
                        Text { text: AccountService.groups; color: root.theme ? root.theme.textMain : "#FFF"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; Layout.fillWidth: true; wrapMode: Text.Wrap }
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
                        color: Qt.rgba(0, 0, 0, 0.3)
                        border.width: 1
                        border.color: nameInput.activeFocus ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.rgba(255, 255, 255, 0.1)
                        Behavior on border.color { ColorAnimation { duration: 150 } }

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
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 40
                        radius: 6
                        color: maName.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.1)
                        opacity: nameInput.text !== AccountService.realName ? 1 : 0.5
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Apply"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: maName.containsMouse ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                        }

                        MouseArea {
                            id: maName
                            anchors.fill: parent
                            enabled: nameInput.text !== AccountService.realName
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
                        color: Qt.rgba(0, 0, 0, 0.3)
                        border.width: 1
                        border.color: passInput.activeFocus ? (root.theme ? root.theme.accentPrimary : "#AAA") : Qt.rgba(255, 255, 255, 0.1)
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        TextInput {
                            id: passInput
                            anchors.fill: parent
                            anchors.margins: 12
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.theme ? root.theme.textMain : "#FFF"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 14
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 40
                        radius: 6
                        color: maPass.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.2)
                        border.width: 1
                        border.color: maPass.containsMouse ? "#ff4444" : Qt.rgba(255, 68, 68, 0.4)
                        opacity: passInput.text.length > 0 ? 1 : 0.5
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Change"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: maPass.containsMouse ? "#FFF" : "#ff4444"
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
