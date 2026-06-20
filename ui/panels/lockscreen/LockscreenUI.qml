import QtQuick
import QtQuick.Controls

import "../../../core"
import "components"
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property var theme: null
    
    // States: "passive" or "auth"
    property string viewState: "passive"
    
    signal authenticate(string password)
    
    function resetState() {
        viewState = "passive";
        authState.clearPassword();
    }
    
    function showError() {
        authState.showError("Incorrect password");
    }
    
    function setStatus(msg) {
        authState.setStatus(msg);
    }
    
    // Background wallpaper
    Image {
        id: bgImage
        anchors.fill: parent
        source: "file:///home/wintrel/Pictures/Koyumi Indoor.png"
        fillMode: Image.PreserveAspectCrop
        visible: false // Hidden by blur
    }
    
    FastBlur {
        anchors.fill: bgImage
        source: bgImage
        radius: 64
        
        // Add a darkening overlay to make text readable
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.4
        }
    }
    
    // State 1: Passive (Clock, Date, minimal)
    PassiveState {
        id: passiveState
        anchors.fill: parent
        theme: root.theme
        
        opacity: root.viewState === "passive" ? 1.0 : 0.0
        visible: opacity > 0
        scale: root.viewState === "passive" ? 1.0 : 0.95
        
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutExpo } }
    }
    
    // State 2: Authentication (Avatar, Password)
    AuthState {
        id: authState
        anchors.fill: parent
        theme: root.theme
        
        opacity: root.viewState === "auth" ? 1.0 : 0.0
        visible: opacity > 0
        scale: root.viewState === "auth" ? 1.0 : 1.05
        
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutExpo } }
        
        onPasswordSubmitted: password => {
            root.authenticate(password);
        }
        onCancel: {
            root.viewState = "passive";
        }
    }
    
    // Global interaction catcher to transition to auth state
    MouseArea {
        anchors.fill: parent
        enabled: root.viewState === "passive"
        onClicked: {
            root.viewState = "auth";
            authState.focusPassword();
        }
    }
    
    focus: true
    Keys.onPressed: event => {
        if (root.viewState === "passive") {
            root.viewState = "auth";
            authState.focusPassword();
            event.accepted = true;
        }
    }
}
