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
        starCount: 30
        starColor: "#ff5555"
        opacity: isActive ? 0.3 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
    }

    Item {
        width: islandMaxW
        height: islandMaxH
        anchors.centerIn: parent

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
                color: Qt.rgba(1, 0, 0, 0.15)
            }

            Text {
                text: "admin_panel_settings"
                font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 24
                color: "#ff4444"
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
                text: PolkitAuthService.authState === 2 ? "Authenticating..." : "System Authentication"
                font.family: theme ? theme.fontMain : "Inter"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: PolkitAuthService.authState === 2 ? "#ff4444" : Qt.rgba(255, 255, 255, 0.6)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: PolkitAuthService.errorMessage !== "" ? PolkitAuthService.errorMessage : PolkitAuthService.currentMessage
                font.family: theme ? theme.fontMain : "Inter"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: PolkitAuthService.errorMessage !== "" ? "#ff5555" : (theme ? theme.textMain : "#FFF")
                anchors.horizontalCenter: parent.horizontalCenter
                width: islandMaxW - 64
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 3
                elide: Text.ElideRight
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
                placeholderText: "Enter Password..."
                placeholderTextColor: Qt.rgba(255,255,255,0.4)
                echoMode: TextInput.Password
                color: "#FFF"
                font.pixelSize: 15
                font.family: theme ? theme.fontMain : "Inter"
                verticalAlignment: TextInput.AlignVCenter
                leftPadding: 24
                rightPadding: 50
                enabled: PolkitAuthService.authState === 1 || PolkitAuthService.authState === 3
                
                background: Item {
                    RectangularGlow {
                        anchors.fill: parent
                        glowRadius: 6
                        spread: 0.1
                        color: Qt.rgba(255, 68, 68, 0.25)
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
                        border.color: pwdField.activeFocus ? "#ff4444" : Qt.rgba(255, 255, 255, 0.08)
                        Behavior on border.color { ColorAnimation { duration: 250 } }
                    }
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
            
            // Submit Arrow
            Rectangle {
                width: 36
                height: 36
                radius: 18
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                color: maSubmit.containsMouse ? "#ff4444" : "transparent"
                
                Text {
                    text: "arrow_forward"
                    font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 20
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
                onClicked: PolkitAuthService.cancel()
            }
        }
    }
}
