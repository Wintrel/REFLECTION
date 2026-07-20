import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    property var theme
    Layout.fillWidth: true
    implicitHeight: mainLayout.implicitHeight + 32
    radius: 12
    color: Qt.rgba(255, 255, 255, 0.02)
    border.width: 1
    border.color: hoverMa.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.05)

    Behavior on border.color { ColorAnimation { duration: 300 } }

    property string iconName: "blur_on"
    property string title: "Reflection Update"

    // Mock State Machine
    property int updateState: 0 // 0: Idle, 1: Available, 2: Updating, 3: Done
    property bool showDetails: false
    
    property var mockPackages: [
        { name: "reflection-core", oldVer: "1.0.0", newVer: "1.0.1" },
        { name: "reflection-ui", oldVer: "1.0.0", newVer: "1.0.2" },
        { name: "wintrel", oldVer: "0.9.8", newVer: "1.0.0" }
    ]
    
    property var mockLogs: [
        "checking for reflection updates...",
        "found 3 updates for reflection.",
        "downloading reflection-core-1.0.1...",
        "downloading reflection-ui-1.0.2...",
        "downloading wintrel-1.0.0...",
        "reloading quickshell components...",
        "applying new styles...",
        "restarting reflection applet...",
        "Done."
    ]
    
    property string logText: ""
    property int logIndex: 0
    property real updateProgress: 0.0
    
    Timer {
        id: updateTimer
        interval: 350
        repeat: true
        running: root.updateState === 2
        onTriggered: {
            if (root.logIndex < root.mockLogs.length) {
                root.logText += root.mockLogs[root.logIndex] + "\n"
                root.logIndex++
                root.updateProgress = root.logIndex / root.mockLogs.length
            } else {
                root.updateState = 3
                root.updateProgress = 1.0
            }
        }
    }

    MouseArea {
        id: hoverMa
        anchors.fill: parent
        hoverEnabled: true
        z: 1
    }

    ColumnLayout {
        id: mainLayout
        z: 2 // Sit above hoverMa so buttons are clickable
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 12

        // Top Row: Icon + Texts + Action Button
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: Qt.rgba(255, 255, 255, 0.05)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.1)

                Text {
                    anchors.centerIn: parent
                    text: root.iconName
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: root.title
                    font.family: "Inter"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }

                Text {
                    text: {
                        if (root.updateState === 0) return "Up to date. Last checked just now.";
                        if (root.updateState === 1) return "3 Updates Available (12.4 MiB)";
                        if (root.updateState === 2) return "Installing Updates... " + Math.floor(root.updateProgress * 100) + "% complete";
                        if (root.updateState === 3) return "Updates Installed. Requires a restart.";
                        return "";
                    }
                    font.family: "Inter"
                    font.pixelSize: 13
                    color: root.theme ? root.theme.textSub : "#888"
                }
            }

            // Action Button
            Rectangle {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 32
                radius: 16
                color: {
                    if (root.updateState === 0) return Qt.rgba(255, 255, 255, 0.1);
                    if (root.updateState === 1) return Qt.rgba(255, 255, 255, 0.2);
                    if (root.updateState === 2) return Qt.rgba(255, 255, 255, 0.1);
                    if (root.updateState === 3) return Qt.rgba(255, 255, 255, 0.2);
                }
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.2)
                z: 2 // Sit above hoverMa
                
                Text {
                    anchors.centerIn: parent
                    text: {
                        if (root.updateState === 0) return "Check";
                        if (root.updateState === 1) return "Update Now";
                        if (root.updateState === 2) return "Cancel";
                        if (root.updateState === 3) return "Restart";
                        return "";
                    }
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.updateState === 0) root.updateState = 1;
                        else if (root.updateState === 1) {
                            root.updateState = 2;
                            root.logText = "";
                            root.logIndex = 0;
                            root.updateProgress = 0.0;
                            root.showDetails = true;
                        }
                        else if (root.updateState === 2) root.updateState = 0; // Cancel
                        else if (root.updateState === 3) root.updateState = 0; // Reset demo
                    }
                }
            }
        }

        // Packages List (State 1)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 8
            visible: root.updateState === 1
            
            Repeater {
                model: root.mockPackages
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

        // Progress & Details (State 2 or 3)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 12
            visible: root.updateState === 2 || root.updateState === 3
            
            // Progress Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                radius: 2
                color: Qt.rgba(255, 255, 255, 0.1)
                clip: true
                
                Rectangle {
                    height: parent.height
                    width: parent.width * root.updateProgress
                    radius: 2
                    color: root.theme ? root.theme.textMain : "#FFF"
                    
                    Behavior on width {
                        NumberAnimation { duration: 300; easing.type: Easing.OutSine }
                    }
                }
            }
            
            // Details Toggle
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 8
                    
                    Text {
                        text: root.showDetails ? "Hide Details" : "Show Details"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                    
                    Text {
                        text: root.showDetails ? "expand_less" : "expand_more"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 16
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
                Layout.preferredHeight: 120
                color: Qt.rgba(0, 0, 0, 0.3) // Dark terminal background
                radius: 8
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.05)
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
                        font.pixelSize: 11
                        color: "#a6adc8"
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
