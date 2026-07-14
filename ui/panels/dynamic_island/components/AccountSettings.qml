import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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
            
            // 1. Account Details (Read Only)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "System Information"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: detailsColumn.height + 24
                    radius: 12
                    color: Qt.rgba(255, 255, 255, 0.03)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.05)
                    
                    ColumnLayout {
                        id: detailsColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
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
            }
            
            // 2. Profile Picture
            RowLayout {
                Layout.fillWidth: true
                spacing: 24
                
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 40
                    color: Qt.rgba(255, 255, 255, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.1)
                    clip: true
                    
                    Image {
                        anchors.fill: parent
                        source: AccountService.profilePicture
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: source.toString() !== ""
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "person"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 32
                        color: root.theme ? root.theme.textMain : "#FFF"
                        visible: parent.children[0].source.toString() === ""
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "Profile Picture"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    Text {
                        text: "This image is displayed on your lock screen and login manager."
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textSub : "#888"
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                    
                    Rectangle {
                        Layout.topMargin: 4
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 32
                        radius: 6
                        color: maPic.containsMouse ? (root.theme ? root.theme.accentPrimary : "#555") : Qt.rgba(255, 255, 255, 0.1)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Choose Image..."
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: maPic.containsMouse ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                        }
                        
                        MouseArea {
                            id: maPic
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                AccountService.pickAndSetProfilePicture();
                            }
                        }
                    }
                }
            }
            
            // 3. Display Name
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
                            hoverEnabled: nameInput.text !== AccountService.realName
                            cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (nameInput.text !== AccountService.realName) {
                                    AccountService.setRealName(nameInput.text);
                                }
                            }
                        }
                    }
                }
            }
            
            // 4. Password
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
}
