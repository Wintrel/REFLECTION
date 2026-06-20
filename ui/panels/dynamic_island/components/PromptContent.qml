import QtQuick
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import "../../../../core/services/system"
import "../../../../core/state" as State

Item {
    id: root
    anchors.fill: parent

    property int islandState: 0
    property var theme: null
    property real islandNotifW: 400
    property real islandNotifH: 100

    opacity: islandState === 6 ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: theme ? theme.animDuration : 300 } }

    onOpacityChanged: {
        if (opacity === 1) {
            pwdField.forceActiveFocus();
        } else {
            pwdField.text = "";
        }
    }

    Item {
        width: islandNotifW
        height: islandNotifH
        anchors.centerIn: parent

        // Icon
        Rectangle {
            id: iconRect
            width: 48
            height: 48
            radius: 24
            color: theme ? Qt.rgba(theme.accentPrimary.r, theme.accentPrimary.g, theme.accentPrimary.b, 0.2) : "#33ff9900"
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                text: PromptService.promptIcon
                font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 24
                color: theme ? theme.accentPrimary : "#ff9900"
                anchors.centerIn: parent
            }
        }

        // Title and Field Column
        Column {
            anchors.left: iconRect.right
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: PromptService.promptTitle
                font.family: theme ? theme.fontMain : "Inter"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: theme ? theme.textMain : "#FFF"
                elide: Text.ElideRight
                width: parent.width
            }

            Row {
                width: parent.width
                spacing: 8

                TextField {
                    id: pwdField
                    width: parent.width - 40
                    height: 36
                    placeholderText: PromptService.isPassword ? "Password..." : "Enter value..."
                    placeholderTextColor: Qt.rgba(255,255,255,0.4)
                    echoMode: PromptService.isPassword ? TextInput.Password : TextInput.Normal
                    color: "#FFF"
                    font.pixelSize: 13
                    font.family: theme ? theme.fontMain : "Inter"
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 12
                    background: Rectangle {
                        color: Qt.rgba(0,0,0,0.3)
                        radius: 6
                        border.width: pwdField.activeFocus ? 1 : 0
                        border.color: theme ? theme.accentPrimary : "#ff9900"
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

                // Cancel/Close Button
                Rectangle {
                    width: 32
                    height: 36
                    radius: 6
                    color: maCancel.containsMouse ? Qt.rgba(255,255,255,0.1) : "transparent"
                    
                    Text {
                        text: "close"
                        font.family: theme ? theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: theme ? theme.textMain : "#FFF"
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        id: maCancel
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PromptService.cancel()
                    }
                }
            }
        }
    }
}
