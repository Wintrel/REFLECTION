pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/quickshell/reflection/.ai_settings.json"
    readonly property string daemonPath: Qt.resolvedUrl("daemon/ai_daemon.js").toString().replace(/^file:\/\//, "")

    property string geminiModel: "gemini-3.6-flash"
    property string groqModel: "llama-3.1-8b-instant"
    property bool geminiConfigured: false
    property bool groqConfigured: false

    readonly property bool running: daemonProcess.running
    property bool healthy: false
    property string daemonStatus: "starting"
    property string lastError: ""
    property int restartCount: 0
    property bool isGenerating: false
    property string activeRequestId: ""
    property bool desiredRunning: true
    property bool restartRequested: false

    signal chunkReceived(string requestId, string text)
    signal generationFinished(string requestId)
    signal generationError(string requestId, string errorMsg)
    signal generationStopped(string requestId)

    function loadSettings() {
        try {
            var cfg = JSON.parse(settingsFile.text() || "{}");
            root.geminiConfigured = typeof cfg.geminiApiKey === "string"
                && cfg.geminiApiKey.trim().length > 0;
            root.groqConfigured = typeof cfg.groqApiKey === "string"
                && cfg.groqApiKey.trim().length > 0;
            root.geminiModel = typeof cfg.geminiModel === "string" && cfg.geminiModel.trim().length > 0
                ? cfg.geminiModel.trim() : "gemini-3.6-flash";
            root.groqModel = typeof cfg.groqModel === "string" && cfg.groqModel.trim().length > 0
                ? cfg.groqModel.trim() : "llama-3.1-8b-instant";
        } catch (error) {
            root.geminiConfigured = false;
            root.groqConfigured = false;
            root.lastError = "Could not read AI settings: " + error;
        }
    }

    function configuredFor(providerId) {
        return providerId === "groq" ? root.groqConfigured : root.geminiConfigured;
    }

    function modelFor(providerId) {
        return providerId === "groq" ? root.groqModel : root.geminiModel;
    }

    function send(command) {
        if (!daemonProcess.running)
            return false;
        daemonProcess.write(JSON.stringify(command) + "\n");
        return true;
    }

    function generate(providerId, model, messages) {
        if (!root.healthy) {
            root.lastError = "The AI daemon is not ready yet.";
            root.generationError("", root.lastError);
            return "";
        }
        if (root.isGenerating) {
            root.lastError = "Another response is already being generated.";
            root.generationError("", root.lastError);
            return "";
        }
        if (!root.configuredFor(providerId)) {
            root.lastError = (providerId === "groq" ? "Groq" : "Gemini") + " API key is not set.";
            root.generationError("", root.lastError);
            return "";
        }

        var requestId = Date.now().toString(36) + "-" + Math.random().toString(36).substring(2, 10);
        root.activeRequestId = requestId;
        root.isGenerating = true;
        root.daemonStatus = "generating";
        if (!send({
            action: "generate",
            requestId: requestId,
            provider: providerId,
            model: model,
            messages: messages
        })) {
            root.isGenerating = false;
            root.activeRequestId = "";
            root.lastError = "The AI daemon stopped before the request could be sent.";
            root.generationError(requestId, root.lastError);
            return "";
        }
        return requestId;
    }

    function stopGeneration() {
        if (!root.isGenerating || root.activeRequestId.length === 0)
            return false;
        return send({ action: "cancel", requestId: root.activeRequestId });
    }

    function startDaemon() {
        root.desiredRunning = true;
        if (!daemonProcess.running) {
            root.daemonStatus = "starting";
            daemonProcess.running = true;
        }
    }

    function stopDaemon() {
        root.desiredRunning = false;
        root.restartRequested = false;
        restartTimer.stop();
        if (daemonProcess.running)
            daemonProcess.running = false;
        else {
            root.healthy = false;
            root.daemonStatus = "stopped";
        }
    }

    function restartDaemon() {
        root.desiredRunning = true;
        root.restartRequested = true;
        restartTimer.stop();
        if (daemonProcess.running) {
            root.daemonStatus = "restarting";
            daemonProcess.running = false;
        } else {
            root.restartRequested = false;
            startDaemon();
        }
    }

    function scheduleRestart() {
        if (!root.desiredRunning)
            return;
        if (!root.restartRequested && root.restartCount >= 5) {
            root.daemonStatus = "failed";
            root.lastError = "The AI daemon stopped repeatedly and automatic restart was paused.";
            return;
        }
        var delay = root.restartRequested ? 150 : Math.min(30000, 500 * Math.pow(2, root.restartCount));
        root.restartRequested = false;
        root.restartCount++;
        root.daemonStatus = "restarting";
        restartTimer.interval = delay;
        restartTimer.restart();
    }

    function handleEvent(event) {
        if (event.type === "ready") {
            root.daemonStatus = "ready";
            root.lastError = "";
            root.healthy = true;
            stableTimer.restart();
        } else if (event.type === "chunk") {
            if (event.requestId === root.activeRequestId)
                root.chunkReceived(event.requestId, event.text || "");
        } else if (event.type === "finished") {
            if (event.requestId === root.activeRequestId) {
                root.isGenerating = false;
                root.activeRequestId = "";
                root.daemonStatus = "ready";
                root.generationFinished(event.requestId);
            }
        } else if (event.type === "stopped") {
            if (event.requestId === root.activeRequestId) {
                root.isGenerating = false;
                root.activeRequestId = "";
                root.daemonStatus = "ready";
                root.generationStopped(event.requestId);
            }
        } else if (event.type === "error") {
            root.lastError = event.message || "Unknown AI daemon error.";
            if (!event.requestId || event.requestId === root.activeRequestId) {
                var failedRequestId = root.activeRequestId || event.requestId || "";
                root.isGenerating = false;
                root.activeRequestId = "";
                root.daemonStatus = root.healthy ? "ready" : "failed";
                root.generationError(failedRequestId, root.lastError);
            }
        }
    }

    FileView {
        id: settingsFile
        path: root.settingsPath
        preload: true
        blockLoading: true
        watchChanges: true
        printErrors: false
        onLoaded: root.loadSettings()
        onFileChanged: reload()
    }

    Process {
        id: daemonProcess
        command: ["node", root.daemonPath, root.settingsPath]
        stdinEnabled: true
        running: root.desiredRunning

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.handleEvent(JSON.parse(data));
                } catch (error) {
                    root.lastError = "Invalid response from the AI daemon: " + error;
                    console.warn("AiDaemonService: " + root.lastError);
                }
            }
        }

        stderr: SplitParser {
            onRead: data => console.warn("AI daemon: " + data)
        }

        onStarted: {
            root.healthy = false;
            root.daemonStatus = "starting";
        }

        onExited: (exitCode, exitStatus) => {
            stableTimer.stop();
            root.healthy = false;
            if (root.isGenerating) {
                var failedRequestId = root.activeRequestId;
                root.isGenerating = false;
                root.activeRequestId = "";
                root.generationError(failedRequestId, "The AI daemon stopped during generation.");
            }
            if (root.desiredRunning)
                root.scheduleRestart();
            else
                root.daemonStatus = "stopped";
        }
    }

    Timer {
        id: restartTimer
        repeat: false
        onTriggered: {
            if (root.desiredRunning && !daemonProcess.running)
                daemonProcess.running = true;
        }
    }

    Timer {
        id: stableTimer
        interval: 30000
        repeat: false
        onTriggered: root.restartCount = 0
    }

    Timer {
        interval: 15000
        repeat: true
        running: root.healthy
        onTriggered: root.send({ action: "ping" })
    }

    Component.onCompleted: root.loadSettings()
}
