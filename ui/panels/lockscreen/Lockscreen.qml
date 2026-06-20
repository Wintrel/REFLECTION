import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

import "../../../core"

ShellRoot {
    id: root

    property string pendingPassword: ""
    
    signal authSuccess()
    signal authFailed()
    signal pamMessage(string msg)

    PamContext {
        id: pamContext
        config: "hyprlock"
        user: Quickshell.env("USER")
        
        onResponseRequiredChanged: {
            if (responseRequired && root.pendingPassword !== "") {
                respond(root.pendingPassword);
                root.pendingPassword = ""; // Clear out immediately
            }
        }
        
        onCompleted: (result) => {
            if (result === 0) { // Success
                console.log("Authentication successful, unlocking...");
                lockManager.locked = false;
                root.authSuccess();
            } else {
                console.log("Authentication failed: " + result);
                root.authFailed();
            }
            root.pendingPassword = "";
        }
        
        onPamMessage: {
            console.log("PAM message: " + message);
            if (message && message !== "") {
                root.pamMessage(message);
            }
        }
    }

    WlSessionLock {
        id: lockManager
        locked: true

        // WlSessionLock expects a Component for its surface layout
        surface: Component {
            WlSessionLockSurface {
                id: surfaceElement
                
                Rectangle {
                    anchors.fill: parent
                    color: "black" 
                    
                    LockscreenUI {
                        id: ui
                        anchors.fill: parent
                        theme: Theme {}
                        
                        Connections {
                            target: root
                            function onAuthSuccess() { ui.resetState(); }
                            function onAuthFailed() { ui.showError(); }
                            function onPamMessage(msg) { ui.setStatus(msg); }
                        }
                        
                        onAuthenticate: password => {
                            root.pendingPassword = password;
                            pamContext.start();
                        }
                    }
                }
            }
        }
    }
}