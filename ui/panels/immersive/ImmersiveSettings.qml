import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../core/state" as State
import "../../../core/services/system"
import "./stages"

// ImmersiveSettings — fullscreen settings with ambient category stages.
// Layout: 240px persistent sidebar (profile + nav + close) | stage area.
// Each category is a self-contained file in ./stages/.
Item {
    id: root
    anchors.fill: parent

    property var theme
    property bool isActive: false
    property bool isSecretUnlocked: false

    // Persists across open/close — remembers last visited category
    property int currentCategory: 0

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

    onIsActiveChanged: {
        if (!isActive) isSecretUnlocked = false;
    }

    opacity: isActive ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    // ──────────────────────────────────────────────────────────────
    // Root layout
    // ──────────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ────────────────────────────────────────
        // SIDEBAR — 240px, always visible
        // ────────────────────────────────────────
        Rectangle {
            id: sidebar
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: root.theme ? Qt.darker(root.theme.bgBase, 1.15) : "#06060A"

            // Slide in from left on open
            opacity: root.isActive ? 1 : 0
            transform: Translate {
                x: root.isActive ? 0 : -24
                Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutExpo } }
            }
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutQuad } }

            // Right-edge separator
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: Qt.rgba(255, 255, 255, 0.05)
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 40
                anchors.bottomMargin: 24
                spacing: 0

                // ── Profile header ─────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.bottomMargin: 8
                    spacing: 14

                    // Avatar
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: root.theme ? root.theme.surfaceOverlay : "#222"
                        border.width: 1.5
                        border.color: root.theme ?
                            Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.4) :
                            Qt.rgba(0.5, 0.5, 1, 0.4)

                        Image {
                            id: avatarImg
                            anchors.fill: parent; anchors.margins: 1.5
                            source: AccountService.profilePicture
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }
                        Rectangle {
                            id: avatarMask
                            anchors.fill: parent; anchors.margins: 1.5
                            radius: 21; visible: false
                        }
                        // Clip avatar to circle via layer-based masking approach
                        Item {
                            anchors.fill: parent; anchors.margins: 1.5
                            clip: true
                            Rectangle {
                                anchors.fill: parent
                                radius: 21
                                color: "transparent"

                                Image {
                                    anchors.fill: parent
                                    source: AccountService.profilePicture
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    visible: source.toString() !== ""
                                }
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "person"
                            font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 22
                            color: root.theme ? root.theme.textSub : "#888"
                            visible: AccountService.profilePicture.toString() === ""
                        }
                    }

                    // Name / subtitle
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            Layout.fillWidth: true
                            text: AccountService.realName || AccountService.username || Quickshell.env("USER")
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: root.theme ? root.theme.textMain : "#FFF"
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "System Settings"
                            font.family: root.theme ? root.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            color: root.theme ? root.theme.textSub : "#888"
                        }
                    }
                }

                // ── Divider ────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.topMargin: 4; Layout.bottomMargin: 12
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.05)
                }

                // ── Nav list ───────────────────────────────────
                ListView {
                    id: navList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 12; Layout.rightMargin: 12
                    model: root.categories
                    spacing: 2
                    interactive: false
                    clip: true

                    delegate: Item {
                        id: navDel
                        width: navList.width
                        height: 44
                        required property string modelData
                        required property int index

                        property bool isSelected: root.currentCategory === navDel.index

                        // Left accent bar
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: -12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: navDel.isSelected ? 28 : 0
                            radius: 2
                            color: root.theme ? root.theme.accentPrimary : "#5151AD"
                            opacity: navDel.isSelected ? 1 : 0
                            Behavior on height  { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                        }

                        // Row background
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: navDel.isSelected ?
                                (root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.10) : Qt.rgba(0.3, 0.3, 0.7, 0.10)) :
                                (navMa.containsMouse ? Qt.rgba(255, 255, 255, 0.04) : "transparent")
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16; anchors.rightMargin: 14
                            spacing: 12

                            Text {
                                text: root.getIconForCategory(navDel.modelData)
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 19
                                color: navDel.isSelected ?
                                    (root.theme ? root.theme.accentPrimary : "#7C7CFF") :
                                    (root.theme ? root.theme.textSub : "#888")
                                Behavior on color { ColorAnimation { duration: 180 } }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: navDel.modelData
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 14
                                font.weight: navDel.isSelected ? Font.DemiBold : Font.Normal
                                color: navDel.isSelected ?
                                    (root.theme ? root.theme.textMain : "#FFF") :
                                    (root.theme ? root.theme.textSub : "#888")
                                Behavior on color { ColorAnimation { duration: 180 } }
                            }
                        }

                        MouseArea {
                            id: navMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentCategory = navDel.index
                        }
                    }
                }

                // ── Bottom divider ─────────────────────────────
                Item { Layout.preferredHeight: 8 }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.bottomMargin: 8
                    height: 1
                    color: Qt.rgba(255, 255, 255, 0.05)
                }

                // ── Close button ───────────────────────────────
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    Layout.leftMargin: 12; Layout.rightMargin: 12

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: closeMa.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            spacing: 12
                            Text {
                                text: "close"
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 19
                                color: root.theme ? root.theme.textSub : "#888"
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Close Settings"
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 13
                                color: root.theme ? root.theme.textSub : "#888"
                            }
                        }

                        MouseArea {
                            id: closeMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: State.GlobalStates.immersiveOpen = false
                        }
                    }
                }
            }
        }

        // ────────────────────────────────────────
        // STAGE AREA — fills remaining width
        // Each CategoryStage controls its own opacity for cross-dissolve.
        // ────────────────────────────────────────
        Item {
            id: stageArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Entrance: fade + slide from right
            opacity: root.isActive ? 1 : 0
            transform: Translate {
                x: root.isActive ? 0 : 32
                Behavior on x { NumberAnimation { duration: 500; easing.type: Easing.OutExpo } }
            }
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: 80 }
                    NumberAnimation { duration: 350; easing.type: Easing.OutQuad }
                }
            }

            // All stages coexist; each manages its own opacity cross-fade
            AccountStage {
                theme: root.theme
                categoryIndex: 0
                isCurrentPage: root.currentCategory === 0
            }
            AudioStage {
                theme: root.theme
                categoryIndex: 1
                isCurrentPage: root.currentCategory === 1
            }
            DisplayStage {
                theme: root.theme
                categoryIndex: 2
                isCurrentPage: root.currentCategory === 2
            }
            PersonalizationStage {
                theme: root.theme
                categoryIndex: 3
                isCurrentPage: root.currentCategory === 3
            }
            BehaviorStage {
                theme: root.theme
                categoryIndex: 4
                isCurrentPage: root.currentCategory === 4
            }
            ShellStage {
                theme: root.theme
                categoryIndex: 5
                isCurrentPage: root.currentCategory === 5
            }
            RogStage {
                theme: root.theme
                categoryIndex: 6
                isCurrentPage: root.currentCategory === 6
            }
            UpdatesStage {
                theme: root.theme
                categoryIndex: 7
                isCurrentPage: root.currentCategory === 7
            }
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
}
