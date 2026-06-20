import QtQuick
import QtQuick.Controls
import Quickshell
import Qt5Compat.GraphicalEffects

import "../../../../core"

Item {
    id: root
    
    property var theme: null
    
    signal passwordSubmitted(string password)
    signal cancel()
    
    function focusPassword() {
        passInput.forceActiveFocus();
    }
    
    function clearPassword() {
        passInput.text = "";
        statusText.text = "Enter password";
        statusText.color = root.theme ? root.theme.textSub : "#AAA";
    }
    
    function setStatus(msg) {
        statusText.text = msg;
        statusText.color = root.theme ? root.theme.textSub : "#AAA";
    }
    
    function showError(msg) {
        statusText.text = msg;
        statusText.color = root.theme ? root.theme.accentError : "#FF4444";
        passInput.text = "";
        focusPassword();
    }
    
    // Pressing Escape goes back to passive view
    Keys.onEscapePressed: {
        root.cancel();
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 24
        
        // Avatar
        Rectangle {
            id: avatarRect
            width: 140
            height: 140
            radius: 60
            color: root.theme ? Qt.rgba(0,0,0,0.5) : "#222"
            anchors.horizontalCenter: parent.horizontalCenter
            border.width: 1
            border.color: root.theme ? Qt.rgba(255,255,255,0.1) : "#333"

            Image {
                id: avatarImg
                anchors.fill: parent
                source: "file:///home/" + (Quickshell.env("USER") || "wintrel") + "/.face.icon"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false // Let OpacityMask handle visibility
                
                onStatusChanged: {
                    console.log("Avatar Image Status: ", status);
                }
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                radius: parent.radius
                visible: false
            }


            OpacityMask {
                anchors.fill: parent
                source: avatarImg
                maskSource: mask
                visible: avatarImg.status === Image.Ready
            }

            Text {
                text: Quickshell.env("USER") ? Quickshell.env("USER").charAt(0).toUpperCase() : "?"
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 64
                font.weight: Font.Light
                color: root.theme ? root.theme.textMain : "#FFF"
                anchors.centerIn: parent
                style: Text.Outline
                styleColor: Qt.rgba(0,0,0,0.4)
                visible: avatarImg.status !== Image.Ready
            }
        }

        // Username
        Text {
            text: Quickshell.env("USER") || "Unknown User"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 36
            font.weight: Font.Medium
            color: root.theme ? root.theme.textMain : "#FFF"
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline
            styleColor: Qt.rgba(0,0,0,0.4)
        }

        // Status message
        Text {
            id: statusText
            text: "" // Hidden by default, only shows on error or pam prompt
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 15
            font.weight: Font.Medium
            color: root.theme ? root.theme.textSub : "#AAA"
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline
            styleColor: Qt.rgba(0,0,0,0.4)
            visible: text !== ""

            Behavior on color { ColorAnimation { duration: 200 } }
        }

        // Password Input Pill
        Rectangle {
            width: 320
            height: 56
            radius: height / 2 // Perfect pill shape
            color: root.theme ? Qt.rgba(0,0,0,0.4) : "#111"
            border.width: 1
            border.color: passInput.activeFocus ? (root.theme ? root.theme.colorNotification : "#710cee") : Qt.rgba(255,255,255,0.1)
            anchors.horizontalCenter: parent.horizontalCenter
            
            Behavior on border.color { ColorAnimation { duration: 200 } }

            TextInput {
                id: passInput
                anchors.fill: parent
                anchors.margins: 16
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 22
                font.weight: Font.Bold
                font.letterSpacing: 4 // Space out the dots
                color: root.theme ? root.theme.textMain : "#FFF"
                echoMode: TextInput.Password
                passwordCharacter: "●"

                Text {
                    text: "Password"
                    color: Qt.rgba(255,255,255,0.4)
                    font.family: parent.font.family
                    font.pixelSize: 16
                    font.letterSpacing: 0
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                    visible: !parent.text && !parent.activeFocus
                }

                onAccepted: {
                    if (text !== "") {
                        root.passwordSubmitted(text);
                    }
                }
            }
        }
    }
}
