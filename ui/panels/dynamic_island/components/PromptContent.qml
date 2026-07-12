import QtQuick
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import "../../../../core/services/system"
import "../../../../core/state" as State
import "../../../components" as Components

Item {
    id: root
    anchors.fill: parent

    property int islandState: 0
    property var theme: null
    property real islandNotifW: 400
    property real islandNotifH: 100

    property bool isActive: islandState === 6
    opacity: isActive ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }

    onOpacityChanged: {
        if (opacity === 1 && PromptService.promptType !== "bluetooth_passkey") {
            pwdField.forceActiveFocus();
        } else {
            pwdField.text = "";
        }
    }

    // Dynamic Starfield Background
    Components.Starfield {
        anchors.fill: parent
        starCount: 25
        // Use theme.accentPrimary for standard prompts
        starColor: theme ? theme.accentPrimary : "#00ffcc"
        opacity: isActive ? 0.3 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
    }

    // Dynamic Edge Glow
    Rectangle {
        anchors.fill: parent
        radius: 36 // Island radius
        color: "transparent"
        
        border.color: {
            if (!isActive) return "transparent"
            var c = theme ? theme.accentPrimary : "#00ffcc"
            // Pulsing logic when focused
            if (PromptService.promptType !== "bluetooth_passkey" && pwdField.activeFocus) {
                return Qt.rgba(c.r, c.g, c.b, pulseGlow.glowOpacity)
            }
            return Qt.rgba(c.r, c.g, c.b, 0.3)
        }
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: 400 } }
        
        // Property for the pulse animation
        QtObject {
            id: pulseGlow
            property real glowOpacity: 0.3
            
            SequentialAnimation on glowOpacity {
                loops: Animation.Infinite
                running: root.isActive && pwdField.activeFocus
                NumberAnimation { from: 0.3; to: 0.6; duration: 800; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.6; to: 0.3; duration: 800; easing.type: Easing.InOutSine }
            }
        }
    }

    Item {
        width: islandNotifW
        height: islandNotifH
        anchors.centerIn: parent

        // ----------------------------------------------------
        // Standard Prompt Layout (e.g. Wi-Fi)
        // ----------------------------------------------------
        Item {
            anchors.fill: parent
            visible: PromptService.promptType !== "bluetooth_passkey"

            Rectangle {
                id: stdIconRect
                width: 48
                height: 48
                radius: 24
                color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.15) : Qt.rgba(0,1,0.8,0.15)
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                
                property bool isVisible: root.isActive && PromptService.promptType !== "bluetooth_passkey"
                opacity: (root.isActive && PromptService.promptType !== "bluetooth_passkey") ? 1 : 0
                transform: Translate {
                    y: (root.isActive && PromptService.promptType !== "bluetooth_passkey") ? 0 : -5
                    Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
                }
                Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
                
                Text {
                    text: PromptService.promptIcon
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: theme ? theme.accentPrimary : "#00ffcc"
                    anchors.centerIn: parent
                    
                    // Subtle pulse
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.isActive
                        NumberAnimation { from: 0.8; to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.0; to: 0.8; duration: 1000; easing.type: Easing.InOutSine }
                    }
                }
            }

            Column {
                anchors.left: stdIconRect.right
                anchors.leftMargin: 16
                anchors.right: stdInputContainer.left
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                
                property bool isVisible: root.isActive && PromptService.promptType !== "bluetooth_passkey"
                opacity: (root.isActive && PromptService.promptType !== "bluetooth_passkey") ? 1 : 0
                transform: Translate {
                    y: (root.isActive && PromptService.promptType !== "bluetooth_passkey") ? 0 : 10
                    Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
                }
                Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

                Text {
                    text: PromptService.promptTitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Qt.rgba(255, 255, 255, 0.6)
                }

                Text {
                    text: PromptService.promptSubtitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: theme ? theme.textMain : "#FFF"
                    elide: Text.ElideRight
                    width: parent.width
                }
            }

            Item {
                id: stdInputContainer
                width: 160
                height: 36
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                
                property bool isVisible: root.isActive && PromptService.promptType !== "bluetooth_passkey"
                opacity: (root.isActive && PromptService.promptType !== "bluetooth_passkey") ? 1 : 0
                transform: Translate {
                    x: (root.isActive && PromptService.promptType !== "bluetooth_passkey") ? 0 : 10
                    Behavior on x { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
                }
                Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
                
                TextField {
                    id: pwdField
                    anchors.fill: parent
                    placeholderText: PromptService.isPassword ? "Password..." : "Enter value..."
                    placeholderTextColor: Qt.rgba(255,255,255,0.4)
                    echoMode: PromptService.isPassword ? TextInput.Password : TextInput.Normal
                    color: "#FFF"
                    font.pixelSize: 13
                    font.family: theme ? theme.fontMain : "Inter"
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 16
                    rightPadding: 36
                    
                    background: Rectangle {
                        color: Qt.rgba(0,0,0,0.5) // Deep void inset
                        radius: 18
                        border.width: pwdField.activeFocus ? 1 : 0
                        border.color: theme ? theme.accentPrimary : "#00ffcc"
                        
                        // Subtle drop shadow inside the textfield to make it look carved
                        layer.enabled: true
                        layer.effect: InnerShadow {
                            color: Qt.rgba(0,0,0,0.8)
                            radius: 4
                            spread: 0.2
                        }
                    }
                    onAccepted: {
                        if (pwdField.text !== "") {
                            PromptService.submit(pwdField.text);
                        }
                    }
                    Keys.onEscapePressed: {
                        PromptService.cancel();
                    }
                }
                
                // Integrated Submit Arrow
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: maStdSubmit.containsMouse ? (theme ? theme.accentPrimary : "#00ffcc") : "transparent"
                    
                    Text {
                        text: "arrow_forward"
                        font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: maStdSubmit.containsMouse ? "#000" : (theme ? theme.accentPrimary : "#00ffcc")
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: maStdSubmit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (pwdField.text !== "") PromptService.submit(pwdField.text);
                        }
                    }
                }
            }

            // Global Cancel Button for Standard Prompt
            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: "transparent"
                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4
                
                Text {
                    text: "close"
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 16
                    color: maGlobalCancel.containsMouse ? "#FFF" : Qt.rgba(255, 255, 255, 0.4)
                    anchors.centerIn: parent
                }
                MouseArea {
                    id: maGlobalCancel
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PromptService.cancel()
                }
            }
        }

        // ----------------------------------------------------
        // Bluetooth Passkey Prompt Layout
        // -----------------------------------------------------
        Item {
            anchors.fill: parent
            visible: PromptService.promptType === "bluetooth_passkey"

            Rectangle {
                id: btIconRect
                width: 48
                height: 48
                radius: 24
                color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.15) : Qt.rgba(0,1,0.8,0.15)
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                
                property bool isVisible: root.isActive && PromptService.promptType === "bluetooth_passkey"
                opacity: (root.isActive && PromptService.promptType === "bluetooth_passkey") ? 1 : 0
                transform: Translate {
                    y: (root.isActive && PromptService.promptType === "bluetooth_passkey") ? 0 : -5
                    Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
                }
                Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
                
                Text {
                    text: PromptService.promptIcon
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: theme ? theme.accentPrimary : "#00ffcc"
                    anchors.centerIn: parent
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.isActive && PromptService.promptType === "bluetooth_passkey"
                        NumberAnimation { from: 0.8; to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.0; to: 0.8; duration: 1000; easing.type: Easing.InOutSine }
                    }
                }
            }

            Column {
                anchors.left: btIconRect.right
                anchors.leftMargin: 16
                anchors.right: btButtons.left
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                
                property bool isVisible: root.isActive && PromptService.promptType === "bluetooth_passkey"
                opacity: (root.isActive && PromptService.promptType === "bluetooth_passkey") ? 1 : 0
                transform: Translate {
                    y: (root.isActive && PromptService.promptType === "bluetooth_passkey") ? 0 : 10
                    Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
                }
                Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

                Text {
                    text: PromptService.promptTitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: Qt.rgba(255, 255, 255, 0.6)
                }

                // Cyberpunk-style glowing code text
                Text {
                    text: PromptService.promptCode
                    font.family: "Monospace"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    font.letterSpacing: 4
                    color: theme ? theme.accentPrimary : "#00ffcc"
                    
                    layer.enabled: true
                    layer.effect: Glow {
                        color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.5) : Qt.rgba(0,1,0.8,0.5)
                        radius: 8
                        spread: 0.2
                    }
                }
            }

            Row {
                id: btButtons
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                
                property bool isVisible: root.isActive && PromptService.promptType === "bluetooth_passkey"
                opacity: (root.isActive && PromptService.promptType === "bluetooth_passkey") ? 1 : 0
                transform: Translate {
                    x: (root.isActive && PromptService.promptType === "bluetooth_passkey") ? 0 : 10
                    Behavior on x { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
                }
                Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
                
                // Confirm Button
                Rectangle {
                    width: 72
                    height: 36
                    radius: 18 // Pill shape
                    color: maBtYes.containsMouse ? (theme ? theme.accentPrimary : "#00ffcc") : Qt.rgba(theme ? theme.accentPrimary.r : 0, theme ? theme.accentPrimary.g : 1, theme ? theme.accentPrimary.b : 0.8, 0.15)
                    border.width: 1
                    border.color: theme ? theme.accentPrimary : "#00ffcc"
                    
                    Text {
                        text: "Accept"
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: maBtYes.containsMouse ? "#000" : (theme ? theme.accentPrimary : "#00ffcc")
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: maBtYes
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PromptService.submit("yes")
                    }
                }
                
                // Reject Button
                Rectangle {
                    width: 72
                    height: 36
                    radius: 18 // Pill shape
                    color: maBtNo.containsMouse ? Qt.rgba(255, 50, 50, 0.8) : Qt.rgba(255, 50, 50, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(255, 50, 50, 0.5)
                    
                    Text {
                        text: "Reject"
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: maBtNo.containsMouse ? "#FFF" : Qt.rgba(255, 100, 100, 1.0)
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: maBtNo
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PromptService.submit("no")
                    }
                }
            }
        }
    }
}
