import QtQuick
import QtQuick.Controls

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
        statusText.text = "";
    }
    
    function setStatus(msg) {
        statusText.text = msg;
        statusText.color = root.theme ? root.theme.textSub : "#AAA";
    }
    
    function showError(msg) {
        statusText.text = msg;
        statusText.color = root.theme ? root.theme.accentError : "#FF4444";
        passInput.text = "";
        
        // Simple shake animation on the text field
        shakeAnim.restart();
        focusPassword();
    }
    
    Item {
        id: container
        anchors.fill: parent
        
        SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: container; property: "x"; from: 0; to: -10; duration: 50 }
            NumberAnimation { target: container; property: "x"; from: -10; to: 10; duration: 50 }
            NumberAnimation { target: container; property: "x"; from: 10; to: -10; duration: 50 }
            NumberAnimation { target: container; property: "x"; from: -10; to: 10; duration: 50 }
            NumberAnimation { target: container; property: "x"; from: 10; to: 0; duration: 50 }
        }
        
        // Status text (above password, or replacing the placeholder)
        Text {
            id: statusText
            anchors.centerIn: parent
            text: ""
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: root.theme ? root.theme.textSub : "#AAA"
            visible: text !== "" && passInput.text === "" && !passInput.activeFocus
        }
        
        TextInput {
            id: passInput
            anchors.fill: parent
            anchors.margins: 8
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 18
            font.weight: Font.Bold
            font.letterSpacing: 4
            color: root.theme ? root.theme.textMain : "#FFF"
            echoMode: TextInput.Password
            passwordCharacter: "●"
            
            Text {
                text: "Unlock"
                color: Qt.rgba(255,255,255,0.3)
                font.family: parent.font.family
                font.pixelSize: 15
                font.letterSpacing: 0
                font.weight: Font.Medium
                anchors.centerIn: parent
                visible: !parent.text && !parent.activeFocus && statusText.text === ""
            }
            
            onAccepted: {
                if (text !== "") {
                    root.passwordSubmitted(text);
                }
            }
            
            Keys.onEscapePressed: {
                root.cancel();
            }
        }
    }
}
