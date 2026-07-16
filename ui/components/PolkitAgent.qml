import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: polkitAgent

    // Public API
    signal showAuthDialog(string actionId, string message, string iconName, string cookie)
    signal showPasswordRequest(string actionId, string request, bool echo, string cookie)
    signal authenticationStateChanged(string cookie, int state)
    signal authorizationResult(bool authorized, string actionId)
    signal authorizationError(string error)
    signal connected()
    signal disconnected()

    property bool isConnected: socket.connected

    // Request authorization for an action
    function checkAuthorization(actionId, details) {
        if (!socket.connected) {
            console.log("Not connected to polkit agent")
            return false
        }

        var message = {
            "type": "check_authorization",
            "action_id": actionId,
            "details": details || ""
        }

        socket.write(JSON.stringify(message) + "\n")
        return true
    }

    // Submit password/response
    function sendPassword(cookie, response) {
        if (!socket.connected) return
        var message = {
            "type": "submit_authentication",
            "cookie": cookie,
            "response": response
        }
        socket.write(JSON.stringify(message) + "\n")
    }

    // Cancel current authorization
    function cancelSession(cookie) {
        if (!socket.connected) return

        var message = {
            "type": "cancel_authorization",
            "cookie": cookie || ""
        }

        socket.write(JSON.stringify(message) + "\n")
    }

    // Private implementation using native Quickshell Socket
    Socket {
        id: socket

        path: {
            var runtimeDir = Quickshell.env("XDG_RUNTIME_DIR")
            if (runtimeDir) {
                return runtimeDir + "/quickshell-polkit/quickshell-polkit"
            } else {
                return "/tmp/quickshell-polkit-" + Quickshell.env("UID") + "/quickshell-polkit"
            }
        }

        parser: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
                if (data.trim().length === 0) return;
                try {
                    var message = JSON.parse(data)
                    handleMessage(message)
                } catch (e) {
                    console.log("Invalid JSON from polkit agent:", e, "Data:", data)
                }
            }
        }

        onConnectionStateChanged: {
            if (connected) {
                console.log("Connected to quickshell-polkit-agent")
                polkitAgent.connected()
            } else {
                console.log("Disconnected from quickshell-polkit-agent")
                polkitAgent.disconnected()
            }
        }

        onError: function(error) {
            console.log("Socket error:", error)
        }

        function connectToAgent() {
            if (connected) {
                return
            }
            connected = true
        }

        // write(data) is provided natively by Socket
    }

    function handleMessage(message) {
        switch (message.type) {
        case "show_auth_dialog":
            polkitAgent.showAuthDialog(
                message.action_id || "",
                message.message || "",
                message.icon_name || "",
                message.cookie || ""
            )
            break

        case "password_request":
            polkitAgent.showPasswordRequest(
                message.action_id || "",
                message.request || "",
                message.echo || false,
                message.cookie || ""
            )
            break

        case "authentication_state":
            polkitAgent.authenticationStateChanged(
                message.cookie || "",
                message.state !== undefined ? message.state : 0
            )
            break

        case "authorization_result":
            polkitAgent.authorizationResult(
                message.authorized,
                message.action_id || ""
            )
            break

        case "authorization_error":
            polkitAgent.authorizationError(message.error || "")
            break

        default:
            console.log("Unknown message type:", message.type)
        }
    }

    // Heartbeat timer to keep the connection to the daemon alive
    Timer {
        id: heartbeatTimer
        interval: 30000 // 30 seconds
        repeat: true
        running: socket.connected
        onTriggered: {
            var message = {
                "type": "heartbeat"
            }
            socket.write(JSON.stringify(message) + "\n")
        }
    }

    // Auto-connect on component creation
    Component.onCompleted: {
        socket.connectToAgent()
    }

    // Auto-reconnect on disconnection (with delay)
    Timer {
        id: reconnectTimer
        interval: 2000 // 2 seconds
        repeat: false
        onTriggered: {
            if (!socket.connected) {
                console.log("Attempting to reconnect to polkit agent...")
                socket.connectToAgent()
            }
        }
    }

    // Start reconnection timer when disconnected
    Connections {
        target: socket
        function onConnectionStateChanged() {
            if (!socket.connected) {
                reconnectTimer.start()
            }
        }
    }
}
