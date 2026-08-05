import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: navigationRail

    property var theme: null
    property bool historyOpen: false
    property bool compact: false
    property int activeContextCount: 0
    property string lastPrompt: ""
    property string activeMode: "Ask"

    property bool clipboardContext: false
    property bool selectionContext: false
    property bool screenContext: false

    signal toggleClipboard()
    signal toggleSelection()
    signal toggleScreen()

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"

    Layout.preferredWidth: historyOpen ? (compact ? Math.min(280, parent.width - 48) : 256) : 0
    Layout.fillHeight: true
    clip: true
    color: theme
        ? Qt.rgba(theme.bgBase.r, theme.bgBase.g, theme.bgBase.b, 0.62)
        : Qt.rgba(0.02, 0.02, 0.03, 0.62)

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutExpo }
    }

    opacity: historyOpen ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

    // Right edge separator
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Qt.rgba(255, 255, 255, 0.05)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Provider status indicator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: 13
            color: providerRailMouse.containsMouse
                ? Qt.rgba(255, 255, 255, 0.055)
                : Qt.rgba(255, 255, 255, 0.032)

            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    width: 7; height: 7; radius: 4
                    color: navigationRail.mutedText
                    opacity: 0.75
                }

                Text {
                    text: "Connect a provider"
                    font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: navigationRail.subText
                }
            }

            MouseArea {
                id: providerRailMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Section label
        Text {
            text: "CONVERSATIONS"
            font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
            font.pixelSize: 9
            font.letterSpacing: 1.3
            font.weight: Font.Bold
            color: navigationRail.mutedText
        }

        // Search bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            radius: 14
            color: Qt.rgba(255, 255, 255, 0.032)
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.06)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 13
                anchors.rightMargin: 13
                spacing: 9

                Text {
                    text: "search"
                    font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 19
                    color: navigationRail.subText
                }

                Text {
                    Layout.fillWidth: true
                    text: "Search conversations"
                    font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    color: navigationRail.mutedText
                }
            }
        }

        // Active conversation card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 68
            radius: 16
            color: Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.12)
            border.width: 1
            border.color: Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.22)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 13
                spacing: 11

                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: 13
                    color: Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.16)

                    Text {
                        anchors.centerIn: parent
                        text: "chat_bubble"
                        font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 19
                        color: navigationRail.accent
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: navigationRail.lastPrompt.length > 0
                            ? (navigationRail.activeMode === "Ask" ? "Conversation" : navigationRail.activeMode)
                            : "New conversation"
                        elide: Text.ElideRight
                        font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: navigationRail.mainText
                    }

                    Text {
                        Layout.fillWidth: true
                        text: navigationRail.lastPrompt.length > 0 ? navigationRail.lastPrompt : "No messages yet"
                        elide: Text.ElideRight
                        font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        color: navigationRail.subText
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // ── Context sources ──
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(navigationRail.mainText.r, navigationRail.mainText.g, navigationRail.mainText.b, 0.06)
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: "CONTEXT SOURCES"
                font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                font.pixelSize: 9
                font.letterSpacing: 1.3
                font.weight: Font.Bold
                color: navigationRail.mutedText
            }

            Text {
                visible: navigationRail.activeContextCount > 0
                text: navigationRail.activeContextCount + " active"
                font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                font.pixelSize: 10
                font.weight: Font.Medium
                color: navigationRail.accent
            }
        }

        AssistantContextOption {
            Layout.fillWidth: true
            theme: navigationRail.theme
            icon: "content_paste"
            title: "Clipboard"
            detail: "Attach clipboard content"
            checked: navigationRail.clipboardContext
            onToggled: navigationRail.toggleClipboard()
        }

        AssistantContextOption {
            Layout.fillWidth: true
            theme: navigationRail.theme
            icon: "text_select_start"
            title: "Selected text"
            detail: "Use active selection"
            checked: navigationRail.selectionContext
            onToggled: navigationRail.toggleSelection()
        }

        AssistantContextOption {
            Layout.fillWidth: true
            theme: navigationRail.theme
            icon: "screenshot_monitor"
            title: "Current screen"
            detail: "Capture on send"
            checked: navigationRail.screenContext
            onToggled: navigationRail.toggleScreen()
        }

        // Privacy note
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            radius: 14
            color: Qt.rgba(255, 255, 255, 0.025)
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.055)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    Layout.alignment: Qt.AlignTop
                    text: "lock"
                    font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: navigationRail.accent
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "History stays local"
                        font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: navigationRail.mainText
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Conversation storage is not yet enabled."
                        wrapMode: Text.WordWrap
                        font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: navigationRail.subText
                    }
                }
            }
        }
    }
}
