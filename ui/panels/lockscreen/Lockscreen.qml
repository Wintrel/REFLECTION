pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io
import Quickshell.Hyprland

import "../../../core"
import "../../../core/state" as State

Scope {
    id: root

    property string pendingPassword: ""
    property bool isUnlocking: false
    
    signal authSuccess()
    signal authFailed()
    signal pamMessage(string msg)

    IpcHandler {
        target: "lock"
        function activate() { State.GlobalStates.screenLocked = true; }
    }

    GlobalShortcut {
        name: "lock"
        description: "Locks the screen"
        onPressed: State.GlobalStates.screenLocked = true
    }

    GlobalShortcut {
        name: "lockFocus"
        description: "Focuses the lock screen"
        onPressed: State.GlobalStates.screenLocked = true
    }

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
                console.log("Authentication successful, playing exit animation...");
                root.isUnlocking = true;
                unlockTimer.start();
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
        locked: State.GlobalStates.screenLocked

        // WlSessionLock expects a Component for its surface layoutt
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
                        isUnlocking: root.isUnlocking
                        
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
    
    Timer {
        id: unlockTimer
        interval: 400
        repeat: false
        onTriggered: {
            State.GlobalStates.screenLocked = false;
            root.isUnlocking = false;
        }
    }
}