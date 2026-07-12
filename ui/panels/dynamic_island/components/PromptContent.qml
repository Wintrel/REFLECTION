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
                    color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.15) : Qt.rgba(0,1,0.8,0.15)
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
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Qt.rgba(255, 255, 255, 0.6)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: PromptService.promptSubtitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
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
                    
                    background: Rectangle {
                        color: Qt.rgba(0,0,0,0.5) // Deep void inset
                        radius: 20
                        border.width: pwdField.activeFocus ? 1 : 0
                        border.color: theme ? theme.accentPrimary : "#00ffcc"
                        
                        layer.enabled: true
                        layer.effect: InnerShadow {
                            color: Qt.rgba(0,0,0,0.8)
                            radius: 6
                            spread: 0.3
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
                    width: 36
                    height: 36
                    radius: 18
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: maSubmit.containsMouse ? (theme ? theme.accentPrimary : "#00ffcc") : "transparent"
                    
                    Text {
                        text: "arrow_forward"
                        font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: maSubmit.containsMouse ? "#000" : (theme ? theme.accentPrimary : "#00ffcc")
                        anchors.centerIn: parent
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
                width: 32
                height: 32
                radius: 16
                color: "transparent"
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                
                Text {
                    text: "close"
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 20
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
                    color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.15) : Qt.rgba(0,1,0.8,0.15)
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
                spacing: 4

                Text {
                    text: PromptService.promptTitle
                    font.family: theme ? theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Qt.rgba(255, 255, 255, 0.6)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Cyberpunk-style glowing code text
                Text {
                    text: PromptService.promptCode
                    font.family: "Monospace"
                    font.pixelSize: 36
                    font.weight: Font.Bold
                    font.letterSpacing: 8
                    color: theme ? theme.accentPrimary : "#00ffcc"
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    layer.enabled: true
                    layer.effect: Glow {
                        color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.5) : Qt.rgba(0,1,0.8,0.5)
                        radius: 12
                        spread: 0.2
                    }
                }
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16
                
                Rectangle {
                    width: 120
                    height: 40
                    radius: 20
                    color: maBtYes.containsMouse ? (theme ? theme.accentPrimary : "#00ffcc") : Qt.rgba(theme ? theme.accentPrimary.r : 0, theme ? theme.accentPrimary.g : 1, theme ? theme.accentPrimary.b : 0.8, 0.15)
                    border.width: 1
                    border.color: theme ? theme.accentPrimary : "#00ffcc"
                    
                    Text {
                        text: "Accept"
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 15
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
                
                Rectangle {
                    width: 120
                    height: 40
                    radius: 20
                    color: maBtNo.containsMouse ? Qt.rgba(255, 50, 50, 0.8) : Qt.rgba(255, 50, 50, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(255, 50, 50, 0.5)
                    
                    Text {
                        text: "Reject"
                        font.family: theme ? theme.fontMain : "Inter"
                        font.pixelSize: 15
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
