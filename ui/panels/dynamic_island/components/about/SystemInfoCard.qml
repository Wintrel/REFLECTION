import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

ColumnLayout {
    id: root
    property var theme
    Layout.fillWidth: true
    spacing: 8

    // --- System Info Processes ---
    Process {
        id: unameProc
        command: ["uname", "-r"]
        running: true
        property string output: ""
        stdout: SplitParser {
            onRead: data => { unameProc.output = data.trim() }
        }
    }

    Process {
        id: osReleaseProc
        command: ["sh", "-c", "grep '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '\"'"]
        running: true
        property string output: ""
        stdout: SplitParser {
            onRead: data => { osReleaseProc.output = data.trim() }
        }
    }

    Process {
        id: uptimeProc
        command: ["uptime", "-p"]
        running: true
        property string output: ""
        stdout: SplitParser {
            onRead: data => { uptimeProc.output = data.trim() }
        }
    }

    Process {
        id: osLogoProc
        command: ["sh", "-c", "LOGO=$(grep '^LOGO=' /etc/os-release | cut -d'=' -f2 | tr -d '\\\"'); [ -z \"$LOGO\" ] && LOGO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '\\\"'); for path in \"/usr/share/pixmaps/$LOGO.svg\" \"/usr/share/pixmaps/$LOGO.png\" \"/usr/share/icons/hicolor/scalable/apps/$LOGO.svg\" \"/usr/share/icons/hicolor/scalable/apps/distributor-logo-$LOGO.svg\"; do if [ -f \"$path\" ]; then echo \"file://$path\"; exit 0; fi; done"]
        running: true
        property string output: ""
        stdout: SplitParser {
            onRead: data => { osLogoProc.output = data.trim() }
        }
    }

    // --- Live Uptime ---
    property int uptimeSeconds: 0
    property bool uptimeInitialized: false

    Process {
        id: uptimeSecsProc
        command: ["sh", "-c", "cut -d' ' -f1 /proc/uptime | cut -d'.' -f1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.uptimeSeconds = parseInt(data.trim()) || 0
                root.uptimeInitialized = true
            }
        }
    }

    Timer {
        running: root.uptimeInitialized && root.visible
        repeat: true
        interval: 1000
        onTriggered: root.uptimeSeconds++
    }

    function formatUptime(totalSec) {
        var days = Math.floor(totalSec / 86400)
        var hours = Math.floor((totalSec % 86400) / 3600)
        var mins = Math.floor((totalSec % 3600) / 60)
        var secs = totalSec % 60
        var parts = []
        if (days > 0) parts.push(days + "d")
        if (hours > 0) parts.push(hours + "h")
        if (mins > 0) parts.push(mins + "m")
        parts.push(secs + "s")
        return parts.join(" ")
    }

    // --- UI ---
    Text {
        text: "System Information"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 18
        font.weight: Font.Bold
        color: root.theme ? root.theme.accentPrimary : "#FFF"
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: sysGrid.implicitHeight + 32
        radius: 8
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.04)

        GridLayout {
            id: sysGrid
            anchors.fill: parent
            anchors.margins: 16
            columns: 2
            columnSpacing: 16
            rowSpacing: 16

            // OS
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item {
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        id: logoImg
                        anchors.fill: parent
                        source: osLogoProc.output
                        sourceSize.width: 48
                        sourceSize.height: 48
                        fillMode: Image.PreserveAspectFit
                        visible: false
                        asynchronous: true
                    }

                    ColorOverlay {
                        anchors.fill: logoImg
                        source: logoImg
                        color: root.theme ? root.theme.accentPrimary : "#AAA"
                        visible: osLogoProc.output !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "linux"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: root.theme ? root.theme.accentPrimary : "#AAA"
                        visible: osLogoProc.output === ""
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "Operating System"; font.family: "Inter"; font.pixelSize: 11; color: root.theme ? root.theme.textSub : "#888" }
                    Text { text: osReleaseProc.output || "Loading..."; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; color: root.theme ? root.theme.textMain : "#FFF" }
                }
            }

            // Kernel
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text { text: "memory"; font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"; font.pixelSize: 20; color: root.theme ? root.theme.accentPrimary : "#AAA" }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Kernel"; font.family: "Inter"; font.pixelSize: 11; color: root.theme ? root.theme.textSub : "#888" }
                    Text { text: unameProc.output || "Loading..."; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; color: root.theme ? root.theme.textMain : "#FFF" }
                }
            }

            // Uptime (live ticking)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text { text: "schedule"; font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"; font.pixelSize: 20; color: root.theme ? root.theme.accentPrimary : "#AAA" }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Uptime"; font.family: "Inter"; font.pixelSize: 11; color: root.theme ? root.theme.textSub : "#888" }
                    Text {
                        text: root.uptimeInitialized ? root.formatUptime(root.uptimeSeconds) : (uptimeProc.output || "Loading...")
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                }
            }

            // Compositor
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text { text: "layers"; font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"; font.pixelSize: 20; color: root.theme ? root.theme.accentPrimary : "#AAA" }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Compositor"; font.family: "Inter"; font.pixelSize: 11; color: root.theme ? root.theme.textSub : "#888" }
                    Text { text: Quickshell.env("WAYLAND_DISPLAY") ? "Wayland (" + (Quickshell.env("XDG_CURRENT_DESKTOP") || "Hyprland") + ")" : "X11"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; color: root.theme ? root.theme.textMain : "#FFF" }
                }
            }

            // Shell
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text { text: "blur_on"; font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"; font.pixelSize: 20; color: root.theme ? root.theme.accentPrimary : "#AAA" }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Shell"; font.family: "Inter"; font.pixelSize: 11; color: root.theme ? root.theme.textSub : "#888" }
                    Text { text: "Reflection v1.6.1"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; color: root.theme ? root.theme.textMain : "#FFF" }
                }
            }

            // Framework
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text { text: "code"; font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"; font.pixelSize: 20; color: root.theme ? root.theme.accentPrimary : "#AAA" }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Framework"; font.family: "Inter"; font.pixelSize: 11; color: root.theme ? root.theme.textSub : "#888" }
                    Text { text: "Quickshell"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; color: root.theme ? root.theme.textMain : "#FFF" }
                }
            }
        }
    }
}
