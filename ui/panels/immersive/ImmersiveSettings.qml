import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../core/state" as State
import "../../../core/services/system"
import "./stages"

// ImmersiveSettings — Reflection's fullscreen control room.
// The top lane deliberately remains clear for the Dynamic Island. The
// navigation rail and workspace sit below it and become non-interactive while
// a system authentication request owns focus.
Item {
    id: root
    anchors.fill: parent

    property var theme
    property bool isActive: false
    property bool isSecretUnlocked: false
    property int currentCategory: 0

    readonly property bool compactNavigation: width < 1150
    readonly property int navigationWidth: compactNavigation ? 84 : 216
    readonly property bool authenticationActive: PolkitAuthService.isAuthenticating

    property var categories: isSecretUnlocked ?
        ["Account", "Audio", "Display", "Personalization", "Behavior", "Shell", "ROG", "Updates", "About", "Wintrel"] :
        ["Account", "Audio", "Display", "Personalization", "Behavior", "Shell", "ROG", "Updates", "About"]

    function getIconForCategory(cat) {
        if (cat === "Account")         return "manage_accounts";
        if (cat === "Audio")           return "headphones";
        if (cat === "Display")         return "desktop_mac";
        if (cat === "Personalization") return "palette";
        if (cat === "Behavior")        return "psychology";
        if (cat === "Shell")           return "desktop_windows";
        if (cat === "ROG")             return "sports_esports";
        if (cat === "Updates")         return "update";
        if (cat === "Wintrel")         return "terminal";
        return "info";
    }

    function groupForIndex(index) {
        if (index === 0) return "PERSONAL";
        if (index === 1) return "HARDWARE";
        if (index === 3) return "EXPERIENCE";
        if (index === 7) return "SYSTEM";
        return "";
    }

    onIsActiveChanged: {
        if (!isActive) isSecretUnlocked = false;
    }

    opacity: isActive ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    // Very soft atmospheric wallpaper. Category stages add their own identity
    // above this layer without competing with the controls.
    Image {
        anchors.fill: parent
        source: WallpaperService.currentWallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0.045
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.28) }
            GradientStop { position: 0.48; color: "transparent" }
            GradientStop {
                position: 1.0
                color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.025) : "transparent"
            }
        }
    }

    // ── Command lane / island clearance ──────────────────────────
    Rectangle {
        id: commandLane
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 72
        color: root.theme ? Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.76) : Qt.rgba(0.03, 0.03, 0.045, 0.76)

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(255, 255, 255, 0.055)
        }

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: root.compactNavigation ? 20 : 28
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 10
                color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.14) : Qt.rgba(0.35, 0.35, 0.8, 0.14)

                Text {
                    anchors.centerIn: parent
                    text: "tune"
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 19
                    color: root.theme ? root.theme.accentPrimary : "#8C8CFF"
                }
            }

            ColumnLayout {
                visible: !root.compactNavigation
                spacing: 0
                Text {
                    text: "REFLECTION"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    font.letterSpacing: 1.6
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accentPrimary : "#8C8CFF"
                }
                Text {
                    text: "Control room"
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
            }
        }

        // Keep the middle of this lane empty: the real Dynamic Island is in a
        // separate layer-shell surface and expands into this space.
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Rectangle {
                visible: root.authenticationActive
                Layout.preferredWidth: authStatusRow.implicitWidth + 24
                Layout.preferredHeight: 34
                radius: 17
                color: Qt.rgba(1, 0.25, 0.25, 0.10)
                border.width: 1
                border.color: Qt.rgba(1, 0.3, 0.3, 0.20)

                RowLayout {
                    id: authStatusRow
                    anchors.centerIn: parent
                    spacing: 7
                    Text {
                        text: "shield_lock"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 16
                        color: "#ff5555"
                    }
                    Text {
                        text: "Authentication required"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: root.compactNavigation ? 38 : 94
                Layout.preferredHeight: 38
                radius: 12
                color: closeArea.containsMouse ? Qt.rgba(255, 255, 255, 0.075) : Qt.rgba(255, 255, 255, 0.035)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.06)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 7
                    Text {
                        text: "close"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: root.theme ? root.theme.textSub : "#AAA"
                    }
                    Text {
                        visible: !root.compactNavigation
                        text: "Close"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        color: root.theme ? root.theme.textSub : "#AAA"
                    }
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    enabled: !root.authenticationActive
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: State.GlobalStates.immersiveOpen = false
                }
            }
        }
    }

    // ── Main control-room layout ─────────────────────────────────
    RowLayout {
        anchors.top: commandLane.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0
        enabled: !root.authenticationActive

        Rectangle {
            id: navigationRail
            Layout.preferredWidth: root.navigationWidth
            Layout.fillHeight: true
            color: root.theme ? Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.62) : Qt.rgba(0.02, 0.02, 0.03, 0.62)

            opacity: root.isActive ? 1 : 0
            transform: Translate {
                x: root.isActive ? 0 : -20
                Behavior on x { NumberAnimation { duration: 420; easing.type: Easing.OutExpo } }
            }
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: Qt.rgba(255, 255, 255, 0.05)
            }

            Flickable {
                anchors.fill: parent
                anchors.topMargin: 14
                anchors.bottomMargin: 92
                contentWidth: width
                contentHeight: navigationColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: navigationColumn
                    width: parent.width

                    Repeater {
                        model: root.categories

                        delegate: Item {
                            id: navDelegate
                            required property string modelData
                            required property int index
                            readonly property bool selected: root.currentCategory === index
                            readonly property string groupLabel: root.groupForIndex(index)
                            width: navigationColumn.width
                            height: 46 + (groupLabel !== "" && !root.compactNavigation ? 30 : 8)

                            Text {
                                visible: navDelegate.groupLabel !== "" && !root.compactNavigation
                                anchors.left: parent.left
                                anchors.leftMargin: 22
                                anchors.top: parent.top
                                anchors.topMargin: 8
                                text: navDelegate.groupLabel
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 9
                                font.letterSpacing: 1.3
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.textMuted : "#666"
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: root.compactNavigation ? 14 : 12
                                anchors.rightMargin: root.compactNavigation ? 14 : 12
                                anchors.bottom: parent.bottom
                                height: 42
                                radius: 12
                                color: navDelegate.selected ?
                                    (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.13) : Qt.rgba(0.4, 0.4, 0.9, 0.13)) :
                                    (navMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.045) : "transparent")
                                border.width: navDelegate.selected ? 1 : 0
                                border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.16) : "transparent"
                                Behavior on color { ColorAnimation { duration: 160 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: root.compactNavigation ? 0 : 13
                                    anchors.rightMargin: 12
                                    spacing: 11

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        Layout.preferredWidth: root.compactNavigation ? parent.width : 22
                                        horizontalAlignment: Text.AlignHCenter
                                        text: root.getIconForCategory(navDelegate.modelData)
                                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                        font.pixelSize: 19
                                        color: navDelegate.selected ? (root.theme ? root.theme.accentPrimary : "#8C8CFF") : (root.theme ? root.theme.textSub : "#888")
                                    }

                                    Text {
                                        visible: !root.compactNavigation
                                        Layout.fillWidth: true
                                        text: navDelegate.modelData
                                        font.family: root.theme ? root.theme.fontMain : "Inter"
                                        font.pixelSize: 13
                                        font.weight: navDelegate.selected ? Font.DemiBold : Font.Normal
                                        color: navDelegate.selected ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#888")
                                    }
                                }

                                MouseArea {
                                    id: navMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentCategory = navDelegate.index
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: root.compactNavigation ? 20 : 18
                anchors.rightMargin: root.compactNavigation ? 20 : 18
                anchors.bottomMargin: 22
                spacing: 11

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: root.theme ? root.theme.surfaceOverlay : "#222"
                    border.width: 1
                    border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.30) : Qt.rgba(0.5, 0.5, 1, 0.3)

                    Item {
                        anchors.fill: parent
                        anchors.margins: 2
                        clip: true
                        Image {
                            anchors.fill: parent
                            source: AccountService.profilePicture
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: source.toString() !== ""
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: AccountService.profilePicture.toString() === ""
                        text: "person"
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 19
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                }

                ColumnLayout {
                    visible: !root.compactNavigation
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        text: AccountService.realName || AccountService.username || Quickshell.env("USER")
                        elide: Text.ElideRight
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    Text {
                        text: "Local account"
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.theme ? root.theme.textMuted : "#666"
                    }
                }
            }
        }

        Rectangle {
            id: workspace
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.theme ? Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.18) : "transparent"
            clip: true

            opacity: root.isActive ? 1 : 0
            transform: Translate {
                x: root.isActive ? 0 : 28
                Behavior on x { NumberAnimation { duration: 480; easing.type: Easing.OutExpo } }
            }
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: 60 }
                    NumberAnimation { duration: 330; easing.type: Easing.OutQuad }
                }
            }

            AccountStage { theme: root.theme; categoryIndex: 0; isCurrentPage: root.currentCategory === 0 }
            AudioStage { theme: root.theme; categoryIndex: 1; isCurrentPage: root.currentCategory === 1 }
            DisplayStage { theme: root.theme; categoryIndex: 2; isCurrentPage: root.currentCategory === 2 }
            PersonalizationStage { theme: root.theme; categoryIndex: 3; isCurrentPage: root.currentCategory === 3 }
            BehaviorStage { theme: root.theme; categoryIndex: 4; isCurrentPage: root.currentCategory === 4 }
            ShellStage { theme: root.theme; categoryIndex: 5; isCurrentPage: root.currentCategory === 5 }
            RogStage { theme: root.theme; categoryIndex: 6; isCurrentPage: root.currentCategory === 6 }
            UpdatesStage { theme: root.theme; categoryIndex: 7; isCurrentPage: root.currentCategory === 7 }
            AboutStage {
                theme: root.theme
                categoryIndex: 8
                isCurrentPage: root.currentCategory === 8
                onSecretUnlocked: root.isSecretUnlocked = true
            }
            WintrelStage {
                theme: root.theme
                categoryIndex: 9
                isCurrentPage: root.currentCategory === 9
                visible: root.isSecretUnlocked
            }
        }
    }

    // A blocking system request belongs to the island, but immersive settings
    // still acknowledge it by dimming and swallowing pointer input below.
    Rectangle {
        anchors.fill: parent
        z: 100
        visible: opacity > 0
        opacity: root.authenticationActive ? 1 : 0
        color: Qt.rgba(0, 0, 0, 0.58)
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        MouseArea { anchors.fill: parent }
    }
}
