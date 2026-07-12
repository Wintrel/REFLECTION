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
    property real islandMaxW: 600
    property real islandMaxH: 200

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
        starCount: 30 // More stars for the bigger canvas
        starColor: theme ? theme.accentPrimary : "#00ffcc"
        opacity: isActive ? 0.3 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
    }

    Item {
        width: islandMaxW
        height: islandMaxH
        anchors.centerIn: parent

        // ----------------------------------------------------
        // Standard Prompt Layout (e.g. Wi-Fi)
        // ----------------------------------------------------
        Item {
            anchors.fill: parent
            opacity: (root.isActive && PromptService.promptType !== "bluetooth_passkey") ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            // 1. The Crown (Top-Center)
            Item {
                id: iconContainer
                width: 48
                height: 48
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    anchors.fill: parent
                    radius: 24
                    color: "transparent"
                    border.width: 1
                    border.color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.25) : Qt.rgba(0,1,0.8,0.25)
                }

                Text {
                    text: PromptService.promptIcon
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: theme ? theme.accentPrimary : "#00ffcc"
                    anchors.centerIn: parent
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.isActive
                        NumberAnimation { from: 0.7; to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.0; to: 0.7; duration: 1500; easing.type: Easing.InOutSine }
                    }
                }
            }

            // 2. The Context (Middle-Center)
            Column {
                anchors.top: iconContainer.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                Text {
                    text: PromptService.promptTitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Light
                    color: Qt.rgba(255, 255, 255, 0.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: PromptService.promptSubtitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 15
                    font.weight: Font.Light
                    color: theme ? theme.textMain : "#FFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // 3. The Input Horizon (Bottom-Center)
            Item {
                id: inputContainer
                width: 400
                height: 40
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                
                TextField {
                    id: pwdField
                    anchors.fill: parent
                    placeholderText: PromptService.isPassword ? "Enter Password..." : "Enter value..."
                    placeholderTextColor: Qt.rgba(255,255,255,0.4)
                    echoMode: PromptService.isPassword ? TextInput.Password : TextInput.Normal
                    color: "#FFF"
                    font.pixelSize: 15
                    font.family: theme ? theme.fontMain : "Inter"
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 24
                    rightPadding: 50
                    
                    background: Item {
                        RectangularGlow {
                            anchors.fill: parent
                            glowRadius: 6
                            spread: 0.1
                            color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.25) : Qt.rgba(0, 1, 0.8, 0.25)
                            cornerRadius: 20 + glowRadius
                            opacity: pwdField.activeFocus ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(0,0,0,0.5) // Deep void inset
                            radius: 20
                            
                            layer.enabled: true
                            layer.effect: InnerShadow {
                                color: Qt.rgba(0,0,0,0.8)
                                radius: 6
                                spread: 0.3
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: 20
                            border.width: 1
                            border.color: pwdField.activeFocus ? (theme ? theme.accentPrimary : "#00ffcc") : Qt.rgba(255,255,255,0.08)
                            Behavior on border.color { ColorAnimation { duration: 250 } }
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
                
                // Submit Arrow
                Rectangle {
                    id: submitBtn
                    width: 36
                    height: 36
                    radius: 18
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    
                    scale: maSubmit.pressed ? 0.92 : (maSubmit.containsMouse ? 1.08 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutSine } }
                    
                    color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, maSubmit.containsMouse ? 0.15 : 0.0) : Qt.rgba(0,1,0.8, maSubmit.containsMouse ? 0.15 : 0.0)
                    border.width: 1
                    border.color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, maSubmit.containsMouse ? 0.4 : 0.0) : Qt.rgba(0,1,0.8, maSubmit.containsMouse ? 0.4 : 0.0)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    
                    Text {
                        text: "arrow_forward"
                        font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: maSubmit.containsMouse ? (theme ? theme.accentPrimary : "#00ffcc") : Qt.rgba(255, 255, 255, 0.4)
                        anchors.centerIn: parent
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    MouseArea {
                        id: maSubmit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (pwdField.text !== "") PromptService.submit(pwdField.text);
                        }
                    }
                }
            }

            // Global Cancel Button (Top Right corner)
            Rectangle {
                id: globalCancelBtn
                width: 32
                height: 32
                radius: 16
                color: "transparent"
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                
                scale: maGlobalCancel.pressed ? 0.92 : (maGlobalCancel.containsMouse ? 1.08 : 1.0)
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutSine } }
                
                Text {
                    text: "close"
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: maGlobalCancel.containsMouse ? "#FFF" : Qt.rgba(255, 255, 255, 0.4)
                    anchors.centerIn: parent
                    Behavior on color { ColorAnimation { duration: 200 } }
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
        // ----------------------------------------------------
        Item {
            anchors.fill: parent
            opacity: (root.isActive && PromptService.promptType === "bluetooth_passkey") ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            Item {
                id: btIconContainer
                width: 48
                height: 48
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    anchors.fill: parent
                    radius: 24
                    color: "transparent"
                    border.width: 1
                    border.color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.25) : Qt.rgba(0,1,0.8,0.25)
                }

                Text {
                    text: PromptService.promptIcon
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: theme ? theme.accentPrimary : "#00ffcc"
                    anchors.centerIn: parent
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.isActive
                        NumberAnimation { from: 0.7; to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.0; to: 0.7; duration: 1500; easing.type: Easing.InOutSine }
                    }
                }
            }

            Column {
                anchors.top: btIconContainer.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    text: PromptService.promptTitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Light
                    color: Qt.rgba(255, 255, 255, 0.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Grid of Passkey characters (thoughtful security design)
                Row {
                    id: codeRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    
                    Repeater {
                        model: PromptService.promptCode ? PromptService.promptCode.length : 0
                        delegate: Item {
                            width: 38
                            height: 48
                            
                            RectangularGlow {
                                anchors.fill: boxRect
                                glowRadius: 4
                                spread: 0.1
                                color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.12) : Qt.rgba(0, 1, 0.8, 0.12)
                                cornerRadius: boxRect.radius + glowRadius
                            }
                            
                            Rectangle {
                                id: boxRect
                                anchors.fill: parent
                                radius: 6
                                color: Qt.rgba(0, 0, 0, 0.4)
                                border.width: 0
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: PromptService.promptCode[index]
                                    font.family: theme ? theme.fontMain : "Inter"
                                    font.pixelSize: 22
                                    font.weight: Font.Light
                                    color: theme ? theme.accentPrimary : "#00ffcc"
                                }
                            }
                        }
                    }
                }
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16
                
                Rectangle {
                    id: btnYes
                    width: 90
                    height: 30
                    radius: 15
                    
                    scale: maBtYes.pressed ? 0.95 : (maBtYes.containsMouse ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutSine } }
                    
                    color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, maBtYes.containsMouse ? 0.15 : 0.0) : Qt.rgba(0, 1, 0.8, maBtYes.containsMouse ? 0.15 : 0.0)
                    border.width: 1
                    border.color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, maBtYes.containsMouse ? 0.5 : 0.2) : Qt.rgba(0, 1, 0.8, maBtYes.containsMouse ? 0.5 : 0.2)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    
                    RectangularGlow {
                        anchors.fill: parent
                        glowRadius: 4
                        spread: 0.1
                        color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.1) : Qt.rgba(0, 1, 0.8, 0.1)
                        cornerRadius: btnYes.radius + glowRadius
                        opacity: maBtYes.containsMouse ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                    
                    Text {
                        text: "Accept"
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.Light
                        color: maBtYes.containsMouse ? "#FFF" : (theme ? theme.accentPrimary : "#00ffcc")
                        anchors.centerIn: parent
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    MouseArea {
                        id: maBtYes
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PromptService.submit("yes")
                    }
                }
                
                Rectangle {
                    id: btnNo
                    width: 90
                    height: 30
                    radius: 15
                    
                    scale: maBtNo.pressed ? 0.95 : (maBtNo.containsMouse ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutSine } }
                    
                    color: Qt.rgba(255, 50, 50, maBtNo.containsMouse ? 0.15 : 0.0)
                    border.width: 1
                    border.color: Qt.rgba(255, 50, 50, maBtNo.containsMouse ? 0.5 : 0.2)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    
                    RectangularGlow {
                        anchors.fill: parent
                        glowRadius: 4
                        spread: 0.1
                        color: Qt.rgba(255, 50, 50, 0.1)
                        cornerRadius: btnNo.radius + glowRadius
                        opacity: maBtNo.containsMouse ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                    
                    Text {
                        text: "Reject"
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.Light
                        color: maBtNo.containsMouse ? "#FFF" : Qt.rgba(255, 100, 100, 0.8)
                        anchors.centerIn: parent
                        Behavior on color { ColorAnimation { duration: 200 } }
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
