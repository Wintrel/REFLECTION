import QtQuick
import "../../../ui/components" as Components

pragma Singleton

Item {
    id: root

    property bool isAuthenticating: false
    property string currentMessage: ""
    property string currentActionId: ""
    property string currentIconName: ""
    property string currentCookie: ""
    property string errorMessage: ""
    
    // 0: None, 1: Password Requested, 2: Authenticating, 3: Failed, 4: Max Retries, 5: Error
    property int authState: 0 

    signal polkitRequestStarted()
    signal polkitRequestFinished()

    Components.PolkitAgent {
        id: agent

        onShowAuthDialog: function(actionId, message, iconName, cookie) {
            root.currentActionId = actionId;
            root.currentMessage = message;
            root.currentIconName = iconName;
            root.currentCookie = cookie;
            root.isAuthenticating = true;
            root.authState = 0;
            root.errorMessage = "";
            root.polkitRequestStarted();
        }

        onShowPasswordRequest: function(actionId, request, echo, cookie) {
            root.currentCookie = cookie;
            root.authState = 1;
        }

        onAuthenticationStateChanged: function(cookie, state) {
            // state: AuthenticationState enum
            // IDLE=0, INITIATED=1, WAITING_FOR_PASSWORD=2, AUTHENTICATING=3, AUTHENTICATION_FAILED=4, MAX_RETRIES_EXCEEDED=5, COMPLETED=6, CANCELLED=7, ERROR=8
            if (state === 2) root.authState = 1;
            else if (state === 3) root.authState = 2;
            else if (state === 4) {
                root.authState = 3;
                root.errorMessage = "Incorrect password. Try again.";
            }
            else if (state === 5) {
                root.authState = 4;
                root.errorMessage = "Too many attempts.";
            }
            else if (state === 8) {
                root.authState = 5;
                root.errorMessage = "An error occurred.";
            }
        }

        onAuthorizationResult: function(authorized, actionId) {
            root.isAuthenticating = false;
            root.polkitRequestFinished();
        }

        onAuthorizationError: function(error) {
            root.errorMessage = "Error: " + error;
            root.authState = 5;
            root.isAuthenticating = false;
            root.polkitRequestFinished();
        }
    }

    function submitPassword(password) {
        if (root.currentCookie !== "") {
            root.authState = 2;
            agent.sendPassword(root.currentCookie, password);
        }
    }

    function cancel() {
        if (root.currentCookie !== "") {
            agent.cancelSession(root.currentCookie);
        }
        root.isAuthenticating = false;
        root.polkitRequestFinished();
    }
}
