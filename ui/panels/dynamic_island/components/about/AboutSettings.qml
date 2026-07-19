import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    // System Info processes
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

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: colLayout.implicitHeight
        clip: true
        
        flickDeceleration: 1000
        maximumFlickVelocity: 4000
        boundsBehavior: Flickable.DragAndOvershootBounds
        
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        
        ColumnLayout {
            id: colLayout
            width: parent.width
            spacing: 32
            
            // Header Image/Logo
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 180
                radius: 12
                color: Qt.rgba(255, 255, 255, 0.02)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.05)
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "blur_on"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 64
                        color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                        
                        layer.enabled: true
                        layer.effect: DropShadow {
                            transparentBorder: true
                            color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                            radius: 16
                            samples: 33
                            opacity: 0.3
                        }
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Reflection"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.weight: Font.Black
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "v1.0.0 (Quickshell)"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                }
            }
            
            // System Information
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "System Information"
                    font.family: "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
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
                                    visible: false // Hidden because ColorOverlay handles rendering
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
                        
                        // Uptime
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            Text { text: "schedule"; font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"; font.pixelSize: 20; color: root.theme ? root.theme.accentPrimary : "#AAA" }
                            ColumnLayout {
                                spacing: 2
                                Text { text: "Uptime"; font.family: "Inter"; font.pixelSize: 11; color: root.theme ? root.theme.textSub : "#888" }
                                Text { text: uptimeProc.output || "Loading..."; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium; color: root.theme ? root.theme.textMain : "#FFF" }
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
                    }
                }
            }
        }
    }
}
