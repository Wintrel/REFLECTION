import QtQuick
import QtQuick.Controls

import "../../../../core"

Item {
    id: root
    
    property var theme: null
    
    // States: "idle", "presence", "media", "auth", "alert"
    property string islandState: "presence"
    
    // Auth specific
    signal passwordSubmitted(string password)
    signal cancel()
    
    function focusPassword() {
        if (islandState === "auth") {
            authContent.focusPassword();
        }
    }
    
    function clearPassword() {
        authContent.clearPassword();
    }
    
    function setStatus(msg) {
        authContent.setStatus(msg);
    }
    
    function showError(msg) {
        authContent.showError(msg);
    }
    
    // Background shape
    Rectangle {
        id: islandBackground
        anchors.horizontalCenter: parent.horizontalCenter
        y: -theme.radiusIsland // Hide top rounded corners like DynamicIslandWidget
        
        // Dimensions based on state
        width: {
            if (islandState === "auth") return 320;
            if (islandState === "presence") return 120; // Small pill
            if (islandState === "idle") return 80;
            return 120;
        }
        
        height: {
            if (islandState === "auth") return 64 + theme.radiusIsland; // Tall enough for text input
            if (islandState === "presence") return 40 + theme.radiusIsland;
            if (islandState === "idle") return 36 + theme.radiusIsland;
            return 40 + theme.radiusIsland;
        }
        
        radius: theme.radiusIsland
        color: theme.bgBezel
        
        Behavior on width {
            NumberAnimation { duration: 400; easing.type: Easing.OutExpo }
        }
        Behavior on height {
            NumberAnimation { duration: 400; easing.type: Easing.OutExpo }
        }
        
        // The inner content container
        Item {
            id: innerContainer
            anchors.fill: parent
            anchors.topMargin: theme.radiusIsland // Shift down to offset the negative Y
            clip: true
            
            // Presence Content (Lock Icon / Notification Badge)
            Item {
                anchors.fill: parent
                opacity: (root.islandState === "presence" || root.islandState === "idle") ? 1.0 : 0.0
                visible: opacity > 0
                
                Behavior on opacity { NumberAnimation { duration: 200 } }
                
                Text {
                    text: "lock" // Material lock icon
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: Qt.rgba(255, 255, 255, 0.7)
                    anchors.centerIn: parent
                }
            }
            
            // Auth Content (Password Input)
            LockscreenIslandAuth {
                id: authContent
                anchors.fill: parent
                theme: root.theme
                opacity: root.islandState === "auth" ? 1.0 : 0.0
                visible: opacity > 0
                
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                
                onPasswordSubmitted: pwd => root.passwordSubmitted(pwd)
                onCancel: root.cancel()
            }
        }
    }
}
