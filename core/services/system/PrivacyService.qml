pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool isMicActive: false
    property bool isCameraActive: false
    property bool isScreenRecording: false
    property bool isMuteAlertActive: false

    readonly property bool isPrivacyActive: isMicActive || isCameraActive || isScreenRecording || isMuteAlertActive

    readonly property color primaryColor: {
        if (isCameraActive) return "#30D158"; // Emerald Green for Camera
        if (isMuteAlertActive) {
            return VolumeService.micIsMuted ? "#FF5555" : "#79D6A1";
        }
        if (isMicActive) {
            return VolumeService.micIsMuted ? "#FF5555" : "#FF9500";
        }
        if (isScreenRecording) return "#FF3B30"; // Vivid Red for Screen Recording
        return "#FF9500";
    }

    readonly property string primaryIcon: {
        if (isCameraActive) return "videocam";
        if (isMuteAlertActive) {
            return VolumeService.micIsMuted ? "mic_off" : "mic";
        }
        if (isMicActive) {
            return VolumeService.micIsMuted ? "mic_off" : "mic";
        }
        if (isScreenRecording) return "screen_record";
        return "privacy_tip";
    }

    function toggleMicMute() {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"] ; onExited: destroy() }', root);
        proc.exited.connect(function() {
            VolumeService.fetchMicVolume();
        });
        proc.running = true;
    }

    // Auto-dismiss the mute/unmute alert after 2.5 seconds
    Timer {
        id: muteAlertTimer
        interval: 2500
        repeat: false
        onTriggered: {
            root.isMuteAlertActive = false;
        }
    }

    Connections {
        target: VolumeService
        function onMicIsMutedChanged() {
            if (VolumeService._micInitialized) {
                root.isMuteAlertActive = true;
                muteAlertTimer.restart();
            }
        }
    }

    Process {
        id: privacyProc
        command: ["python3", "-u", Qt.resolvedUrl("privacy_watcher.py").toString().replace(/^file:\/\//, "")]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (!line) return;
                try {
                    var state = JSON.parse(line);
                    root.isMicActive = !!state.mic;
                    root.isCameraActive = !!state.cam;
                    root.isScreenRecording = !!state.screen;
                } catch(e) {}
            }
        }
    }
}
