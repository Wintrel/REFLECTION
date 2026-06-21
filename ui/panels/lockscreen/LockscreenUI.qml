import QtQuick
import QtQuick.Controls
import Quickshell

import "../../../core"
import "components"
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property var theme: null
    
    // States: "passive" or "auth"
    property string viewState: "passive"
    property bool isLoaded: false
    property bool isUnlocking: false
    
    Component.onCompleted: {
        isLoaded = true;
    }
    
    signal authenticate(string password)
    signal playExitAnimation()
    
    function resetState() {
        viewState = "passive";
        lockscreenIsland.clearPassword();
    }
    
    function showError() {
        lockscreenIsland.showError("Incorrect password");
    }
    
    function setStatus(msg) {
        lockscreenIsland.setStatus(msg);
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
        opacity: root.isLoaded && !root.isUnlocking ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
        
        // Add a darkening overlay to make text readable
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.4
        }
    }
    
    // Center Content Container (Clock and Avatar)
    Item {
        id: centerContent
        anchors.centerIn: parent
        width: parent.width
        height: 600
        
        // When loaded, move to normal position. When unlocking, fly UP to exit.
        // When in auth state, shift up slightly (-160)
        anchors.verticalCenterOffset: {
            if (root.isUnlocking) return -300;
            if (!root.isLoaded) return 50; // Start slightly lower
            if (root.viewState === "passive") return 0;
            return -160;
        }
        
        opacity: root.isLoaded && !root.isUnlocking ? 1.0 : 0.0
        
        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 700; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
        
        // Passive State (Clock and Date)
        PassiveState {
            id: passiveState
            anchors.centerIn: parent
            theme: root.theme
            
            // Clock stays fully visible, but scales down to give focus to the avatar
            opacity: 1.0
            scale: root.viewState === "passive" ? 1.0 : 0.75
            
            Behavior on scale { NumberAnimation { duration: 700; easing.type: Easing.OutExpo } }
        }
        
        // Auth State Avatar
        Item {
            id: authAvatar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 150 // Position it further below the clock
            width: 200
            height: 200
            
            // Fades in and scales up when authenticating
            opacity: root.viewState === "auth" ? 1.0 : 0.0
            visible: opacity > 0
            scale: root.viewState === "auth" ? 1.0 : 0.95
            
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
            Behavior on scale { NumberAnimation { duration: 700; easing.type: Easing.OutExpo } }
            
            Column {
                anchors.centerIn: parent
                spacing: 24
                
                Rectangle {
                    width: 160
                    height: 160
                    radius: 90
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
                        visible: false
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

                Text {
                    text: Quickshell.env("USER") || "Unknown User"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 32
                    font.weight: Font.Medium
                    color: root.theme ? root.theme.textMain : "#FFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                    style: Text.Outline
                    styleColor: Qt.rgba(0,0,0,0.4)
                }
            }
        }
    }
    
    // Top-anchored Lockscreen Island
    LockscreenIsland {
        id: lockscreenIsland
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        
        // Starts hidden above the screen, drops down on load, flies back up on unlock
        anchors.topMargin: (root.isLoaded && !root.isUnlocking) ? 0 : -200
        Behavior on anchors.topMargin { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
        
        theme: root.theme
        
        // Link island state to view state
        islandState: root.viewState === "auth" ? "auth" : "presence"
        
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
            lockscreenIsland.focusPassword();
        }
    }
    
    focus: true
    Keys.onPressed: event => {
        if (root.viewState === "passive") {
            root.viewState = "auth";
            lockscreenIsland.focusPassword();
            event.accepted = true;
        }
    }
}
