import QtQuick
import QtQuick.Controls.Basic
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

    // islandState === 10 is Polkit
    property bool isActive: islandState === 10
    opacity: isActive ? 1 : 0
    visible: opacity > 0
    layer.enabled: true
    Behavior on opacity { enabled: false; NumberAnimation { duration: 0 } }

    onOpacityChanged: {
        if (opacity === 1 && PolkitAuthService.authState === 1) {
            pwdField.forceActiveFocus();
        } else {
            pwdField.text = "";
        }
    }

    // Red Dwarf Starfield Background Effect
    Components.Starfield {
        anchors.fill: parent
        starCount: 25
        starColor: "#ff5555"
        opacity: isActive ? 0.3 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
    }

    // Subtle red glow on the edges
    Rectangle {
        anchors.fill: parent
        radius: 36 // Island radius
        color: "transparent"
        border.color: isActive ? Qt.rgba(1, 0.2, 0.2, 0.3) : "transparent"
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: 400 } }
    }

    Item {
        width: islandNotifW
        height: islandNotifH
        anchors.centerIn: parent

        Rectangle {
            id: iconRect
            width: 48
            height: 48
            radius: 24
            color: Qt.rgba(1, 0, 0, 0.15)
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            
            opacity: isActive ? 1 : 0
            transform: Translate {
                y: isActive ? 0 : -5
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 0 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
            
            Text {
                text: "admin_panel_settings" // Lock/Admin icon
                font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 24
                color: "#ff4444"
                anchors.centerIn: parent
                
                // Subtle pulse for the icon
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: isActive
                    NumberAnimation { from: 0.8; to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.8; duration: 1000; easing.type: Easing.InOutSine }
                }
            }
        }

        Column {
            anchors.left: iconRect.right
            anchors.leftMargin: 16
            anchors.right: inputContainer.left
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            
            opacity: isActive ? 1 : 0
            transform: Translate {
                y: isActive ? 0 : 10
                Behavior on y { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 50 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }

            Text {
                text: PolkitAuthService.authState === 2 ? "Authenticating..." : "System Authentication"
                font.family: theme ? theme.fontMain : "Inter"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: PolkitAuthService.authState === 2 ? "#ff4444" : Qt.rgba(255, 255, 255, 0.6)
            }

            Text {
                text: PolkitAuthService.errorMessage !== "" ? PolkitAuthService.errorMessage : PolkitAuthService.currentMessage
                font.family: theme ? theme.fontMain : "Inter"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: PolkitAuthService.errorMessage !== "" ? "#ff5555" : (theme ? theme.textMain : "#FFF")
                elide: Text.ElideRight
                width: parent.width
            }
        }

        Item {
            id: inputContainer
            width: 160
            height: 36
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            
            opacity: isActive ? 1 : 0
            transform: Translate {
                x: isActive ? 0 : 10
                Behavior on x { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
            }
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
            
            TextField {
                id: pwdField
                anchors.fill: parent
                placeholderText: "Password..."
                placeholderTextColor: Qt.rgba(255,255,255,0.4)
                echoMode: TextInput.Password
                color: "#FFF"
                font.pixelSize: 13
                font.family: theme ? theme.fontMain : "Inter"
                verticalAlignment: TextInput.AlignVCenter
                leftPadding: 16
                rightPadding: 36
                enabled: PolkitAuthService.authState === 1 || PolkitAuthService.authState === 3
                
                background: Rectangle {
                    color: Qt.rgba(0,0,0,0.5) // Darker void background
                    radius: 18
                    border.width: pwdField.activeFocus ? 1 : 0
                    border.color: "#ff4444"
                }
                onAccepted: {
                    if (pwdField.text !== "") {
                        PolkitAuthService.submitPassword(pwdField.text);
                        pwdField.text = ""; // clear after submit
                    }
                }
                Keys.onEscapePressed: {
                    PolkitAuthService.cancel();
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
                color: maSubmit.containsMouse ? "#ff4444" : "transparent"
                
                Text {
                    text: "arrow_forward"
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: maSubmit.containsMouse ? "#000" : "#ff4444"
                    anchors.centerIn: parent
                }
                MouseArea {
                    id: maSubmit
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (pwdField.text !== "") {
                            PolkitAuthService.submitPassword(pwdField.text);
                            pwdField.text = "";
                        }
                    }
                }
            }
        }

        // Global Cancel Button
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
                color: maCancel.containsMouse ? "#FFF" : Qt.rgba(255, 255, 255, 0.4)
                anchors.centerIn: parent
            }
            MouseArea {
                id: maCancel
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PolkitAuthService.cancel()
            }
        }
    }
}
