pragma Singleton
import QtQuick

Item {
    id: root

    property bool inProgress: false
    property string statusText: ""
    property string statusIcon: ""
    
    // Properties for resolution state
    property bool isResolving: false
    property bool isSuccess: false

    signal actionRequested()
    
    property var _startTime: 0
    property var _pendingFinished: null
    
    // Context awareness
    property string lastActionContext: ""
    property var lastActionTime: 0

    Timer {
        id: delayTimer
        repeat: false
        onTriggered: {
            if (root._pendingFinished) {
                root.applyFinished(root._pendingFinished.text, root._pendingFinished.icon, root._pendingFinished.success);
                root._pendingFinished = null;
            }
        }
    }

    function actionStarted(text, icon, context) {
        delayTimer.stop();
        _pendingFinished = null;
        _startTime = Date.now();
        lastActionTime = Date.now();
        lastActionContext = context || "";
        
        statusText = text;
        statusIcon = icon;
        inProgress = true;
        isResolving = false;
        isSuccess = false;

        actionRequested();
    }

    function actionFinished(text, icon, success) {
        var elapsed = Date.now() - _startTime;
        var minTime = 1700; // Force at least 1.7 seconds of "Connecting..."
        
        if (elapsed < minTime) {
            _pendingFinished = { text: text, icon: icon, success: success };
            delayTimer.interval = minTime - elapsed;
            delayTimer.restart();
        } else {
            applyFinished(text, icon, success);
        }
    }
    
    function applyFinished(text, icon, success) {
        statusText = text;
        statusIcon = icon;
        isSuccess = success;

        inProgress = false;
        isResolving = true;
    }

    function reset() {
        delayTimer.stop();
        _pendingFinished = null;
        inProgress = false;
        isResolving = false;
        statusText = "";
        statusIcon = "";
    }
}
