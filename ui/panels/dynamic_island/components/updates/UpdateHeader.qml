import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../components" as GlobalComponents

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    implicitHeight: Math.max(200, mainContentLayout.implicitHeight + 40)

    property string iconName: "system_update"
    property string title: "System Update"

    // Mock State Machine
    property int updateState: 0 // 0: Idle, 1: Checking, 2: Available, 3: Updating, 4: Done
    property bool showDetails: false
    
    signal checkUpdatesRequested()
    signal updateRequested()
    
    property var updatePackages: []
    property int totalDownloadSizeMB: 0
    
    property var mockLogs: [
        "resolving dependencies...",
        "looking for conflicting packages...",
        "Packages (5) firefox-126.0 linux-firmware-20240510-1 mesa-24.1.2 systemd-256.0 wayland-1.23.0",
        "Total Download Size:   180.20 MiB",
        "Total Installed Size:  540.60 MiB",
        ":: Proceed with installation? [Y/n]",
        "downloading firefox-126.0-x86_64.pkg.tar.zst...",
        "downloading linux-firmware-20240510-1-any.pkg.tar.zst...",
        "downloading mesa-24.1.2-x86_64.pkg.tar.zst...",
        "checking keyring...",
        "checking package integrity...",
        "loading package files...",
        "checking for file conflicts...",
        "upgrading linux-firmware...",
        "upgrading mesa...",
        "upgrading systemd...",
        "upgrading wayland...",
        "upgrading firefox...",
        "running post-transaction hooks...",
        "Updating linux initcpios...",
        "Done."
    ]
    
    property string logText: ""
    property int logIndex: 0
    property real updateProgress: 0.0
    
    Timer {
        id: updateTimer
        interval: 350
        repeat: true
        running: root.updateState === 3
        onTriggered: {
            if (root.logIndex < root.mockLogs.length) {
                root.logText += root.mockLogs[root.logIndex] + "\n"
                root.logIndex++
                root.updateProgress = root.logIndex / root.mockLogs.length
            } else {
                root.updateState = 4
                root.updateProgress = 1.0
            }
        }
    }

    Rectangle {
        id: headerBg
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: headerMa.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.05)

        Behavior on border.color { ColorAnimation { duration: 300 } }

        MouseArea {
            id: headerMa
            anchors.fill: parent
            hoverEnabled: true
            z: 1
        }

        // Rounded mask for visual content clipping
        Rectangle {
            id: contentMask
            anchors.fill: parent
            radius: 12
            visible: false
        }

        // All background visual layers (masked to rounded rect)
        Item {
            id: bgContent
            anchors.fill: parent

            // Base fill
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(255, 255, 255, 0.02)
            }

            // Breathing radial gradient
            RadialGradient {
                anchors.fill: parent

                property real cx: 0
                property real cy: 0

                SequentialAnimation on cx {
                    loops: Animation.Infinite
                    running: root.visible
                    NumberAnimation { to: 30; duration: 8000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: -30; duration: 8000; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on cy {
                    loops: Animation.Infinite
                    running: root.visible
                    NumberAnimation { to: 20; duration: 10000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: -20; duration: 10000; easing.type: Easing.InOutSine }
                }

                horizontalOffset: cx
                verticalOffset: cy

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: {
                            if (root.theme) {
                                var c = root.theme.accentPrimary
                                return Qt.rgba(c.r, c.g, c.b, 0.06)
                            }
                            return Qt.rgba(0.29, 0.87, 0.5, 0.06)
                        }
                    }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Back starfield layer
            GlobalComponents.Starfield {
                anchors.fill: parent
                starCount: 25
                starColor: root.theme ? root.theme.textSub : "#888"
                opacity: 0.25

                transform: Translate {
                    y: headerMa.containsMouse ? -3 : 0
                    Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
            }

            // Mid starfield layer
            GlobalComponents.Starfield {
                anchors.fill: parent
                starCount: 35
                starColor: "#FFFFFF"
                opacity: 0.35
            }

            // Front starfield layer
            GlobalComponents.Starfield {
                anchors.fill: parent
                starCount: 20
                starColor: root.theme ? root.theme.accentPrimary : "#4ADE80"
                opacity: 0.5

                transform: Translate {
                    y: headerMa.containsMouse ? 3 : 0
                    Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: contentMask
            }
        }

        // --- Foreground content ---
        ColumnLayout {
            id: mainContentLayout
            z: 2 // Sit above headerMa so buttons are clickable
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 12

            // Animated logo icon
            Text {
                id: logoIcon
                Layout.alignment: Qt.AlignHCenter
                text: root.iconName
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 64
                color: root.theme ? root.theme.accentPrimary : "#4ADE80"

                transformOrigin: Item.Center
                scale: headerMa.containsMouse ? 1.12 : 1.0
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

                RotationAnimator on rotation {
                    id: rotAnim
                    from: 0
                    to: 360
                    duration: 25000
                    loops: Animation.Infinite
                    running: true
                }

                Connections {
                    target: headerMa
                    function onContainsMouseChanged() {
                        rotAnim.duration = headerMa.containsMouse ? 8000 : 25000
                    }
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    id: logoGlow
                    transparentBorder: true
                    color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                    radius: headerMa.containsMouse ? 24 : 16
                    samples: 49

                    property real pulseOpacity: 0.3
                    SequentialAnimation on pulseOpacity {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 0.8; duration: 2500; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.3; duration: 2500; easing.type: Easing.InOutSine }
                    }

                    opacity: headerMa.containsMouse ? 0.6 : pulseOpacity
                    Behavior on radius { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
                }
            }

            // Gradient title
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: titleText.implicitWidth
                height: titleText.implicitHeight

                Text {
                    id: titleText
                    text: root.title
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.weight: Font.Black
                    color: "white"
                    visible: false
                }

                LinearGradient {
                    anchors.fill: parent
                    source: titleText
                    start: Qt.point(0, 0)
                    end: Qt.point(width, height)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.theme ? root.theme.textMain : "#FFF" }
                        GradientStop { position: 1.0; color: root.theme ? root.theme.accentPrimary : "#4ADE80" }
                    }
                }
            }

            // Dynamic Taglines based on State
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: {
                    if (root.updateState === 0) return "System is up to date. Last checked just now.";
                    if (root.updateState === 1) return "Checking for updates...";
                    if (root.updateState === 2) return root.updatePackages.length + " Updates Available";
                    if (root.updateState === 3) return "Installing Updates... " + Math.floor(root.updateProgress * 100) + "% complete";
                    if (root.updateState === 4) return "Updates Installed. Requires a restart.";
                    return "";
                }
                font.family: "Inter"
                font.pixelSize: 13
                color: root.theme ? root.theme.textSub : "#888"
            }

            // Action Button
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 140
                Layout.preferredHeight: 36
                Layout.topMargin: 8
                radius: 18
                color: {
                    if (root.updateState === 0) return Qt.rgba(255, 255, 255, 0.1);
                    if (root.updateState === 1) return Qt.rgba(255, 255, 255, 0.1);
                    if (root.updateState === 2) return root.theme ? root.theme.accentPrimary : "#4ADE80";
                    if (root.updateState === 3) return Qt.rgba(255, 255, 255, 0.1);
                    if (root.updateState === 4) return root.theme ? root.theme.accentPrimary : "#4ADE80";
                }
                border.width: root.updateState === 0 || root.updateState === 1 || root.updateState === 3 ? 1 : 0
                border.color: Qt.rgba(255, 255, 255, 0.2)
                z: 2 // Make sure it sits above background mousearea
                
                Text {
                    anchors.centerIn: parent
                    text: {
                        if (root.updateState === 0) return "Check for Updates";
                        if (root.updateState === 1) return "Checking...";
                        if (root.updateState === 2) return "Update Now";
                        if (root.updateState === 3) return "Cancel";
                        if (root.updateState === 4) return "Restart Now";
                        return "";
                    }
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: (root.updateState === 2 || root.updateState === 4) ? "#000" : (root.theme ? root.theme.textMain : "#FFF")
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.updateState === 0) {
                            root.updateState = 1;
                            root.checkUpdatesRequested();
                        }
                        else if (root.updateState === 2) {
                            root.updateState = 3;
                            root.logText = "";
                            root.logIndex = 0;
                            root.updateProgress = 0.0;
                            root.showDetails = true;
                            root.updateRequested();
                        }
                        else if (root.updateState === 3) root.updateState = 0; // Cancel
                        else if (root.updateState === 4) root.updateState = 0; // Reset demo
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(255, 255, 255, 0.1)
                visible: root.updateState === 2 || root.updateState === 3
                Layout.topMargin: 8
            }
            
            // Packages List (State 2)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: root.updateState === 2
                
                Text {
                    text: "Packages to be updated:"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(pkgLayout.implicitHeight, 130)
                    contentHeight: pkgLayout.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: pkgLayout
                        width: parent.width
                        spacing: 8
                        
                        Repeater {
                            model: root.updatePackages
                            delegate: RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.name
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 13
                                    color: root.theme ? root.theme.textMain : "#FFF"
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.oldVer + " → " + modelData.newVer
                                    font.family: root.theme ? root.theme.fontMain : "Inter"
                                    font.pixelSize: 13
                                    color: root.theme ? root.theme.textSub : "#888"
                                }
                            }
                        }
                    }
                }
            }
            
            // Progress & Details (State 3 or 4)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.updateState === 3 || root.updateState === 4
                
                // Progress Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: Qt.rgba(255, 255, 255, 0.1)
                    clip: true
                    
                    Rectangle {
                        height: parent.height
                        width: parent.width * root.updateProgress
                        radius: 3
                        color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                        
                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutSine }
                        }
                    }
                }
                
                // Details Toggle
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    
                    RowLayout {
                        anchors.fill: parent
                        spacing: 8
                        
                        Text {
                            text: root.showDetails ? "Hide Details" : "Show Details"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 13
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                        
                        Text {
                            text: root.showDetails ? "expand_less" : "expand_more"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 18
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        z: 2
                        onClicked: root.showDetails = !root.showDetails
                    }
                }
                
                // Terminal Output Box
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: "#0a0a0f" // Dark terminal background
                    radius: 8
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.1)
                    visible: root.showDetails
                    clip: true
                    z: 2
                    
                    Flickable {
                        id: termFlick
                        anchors.fill: parent
                        anchors.margins: 12
                        contentWidth: width
                        contentHeight: termText.implicitHeight
                        clip: true
                        
                        // Auto-scroll to bottom
                        onContentHeightChanged: {
                            if (contentHeight > height) {
                                contentY = contentHeight - height
                            }
                        }
                        
                        Text {
                            id: termText
                            width: parent.width
                            text: root.logText
                            font.family: "Monospace"
                            font.pixelSize: 12
                            color: "#cdd6f4" // Light text
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }
}
