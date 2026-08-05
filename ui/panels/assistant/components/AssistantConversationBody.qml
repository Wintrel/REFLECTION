import QtQuick
import QtQuick.Layouts
import "../../../../core/services/ai"

Item {
    id: conversationBody

    property var theme: null
    property bool compact: false
    property string activeMode: "Ask"

    signal intentSelected(string mode, string prompt)

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"

    function greeting() {
        var hour = new Date().getHours();
        if (hour < 5) return "A quiet place to think";
        if (hour < 12) return "Good morning";
        if (hour < 18) return "Good afternoon";
        return "Good evening";
    }

    // Active conversation: message list
    ListView {
        id: conversationList
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        visible: ConversationService.hasMessages
        model: ConversationService.messages
        spacing: 20
        topMargin: 18
        bottomMargin: 18
        leftMargin: conversationBody.compact ? 20 : 32
        rightMargin: conversationBody.compact ? 20 : 32

        delegate: Item {
            id: messageDelegate
            required property string role
            required property string text
            required property string status

            width: conversationList.width - conversationList.leftMargin - conversationList.rightMargin
            height: role === "user" ? userBubble.height : assistantMessage.height

            Rectangle {
                id: userBubble
                visible: messageDelegate.role === "user"
                anchors.right: parent.right
                width: Math.min(userPromptText.implicitWidth + 36, parent.width * 0.68)
                height: userPromptText.implicitHeight + 28
                radius: 18
                color: Qt.rgba(conversationBody.accent.r, conversationBody.accent.g, conversationBody.accent.b, 0.16)

                Text {
                    id: userPromptText
                    anchors.fill: parent
                    anchors.margins: 14
                    text: messageDelegate.text
                    wrapMode: Text.WordWrap
                    font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
                    font.pixelSize: 15
                    lineHeight: 1.3
                    color: conversationBody.mainText
                }
            }

            Row {
                id: assistantMessage
                visible: messageDelegate.role === "assistant"
                width: parent.width
                height: Math.max(36, assistantContent.implicitHeight)
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 12
                    color: Qt.rgba(conversationBody.accent.r, conversationBody.accent.g, conversationBody.accent.b, 0.14)

                    Text {
                        anchors.centerIn: parent
                        text: "auto_awesome"
                        font.family: conversationBody.theme ? conversationBody.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 19
                        color: conversationBody.accent
                    }
                }

                Column {
                    id: assistantContent
                    width: Math.min(parent.width - 48, 720)
                    spacing: 7

                    Text {
                        text: "Reflection"
                        font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: conversationBody.mainText
                    }

                    Text {
                        width: parent.width
                        text: messageDelegate.text.length > 0
                            ? messageDelegate.text
                            : (messageDelegate.status === "streaming" ? "Thinking..." : "")
                        textFormat: Text.MarkdownText
                        wrapMode: Text.WordWrap
                        linkColor: conversationBody.accent
                        font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
                        font.pixelSize: 15
                        lineHeight: 1.35
                        color: conversationBody.subText
                        onLinkActivated: link => {
                            var url = link.toString();
                            if (url.startsWith("https://") || url.startsWith("http://"))
                                Qt.openUrlExternally(url);
                        }
                    }
                }
            }
        }

        Connections {
            target: ConversationService
            function onRevisionChanged() {
                Qt.callLater(function() { conversationList.positionViewAtEnd(); });
            }
        }

        Component.onCompleted: positionViewAtEnd()
    }

    // Empty state: greeting + intent cards
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        width: parent.width - (conversationBody.compact ? 40 : 64)
        spacing: 18
        visible: !ConversationService.hasMessages

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "auto_awesome"
            font.family: conversationBody.theme ? conversationBody.theme.fontIcon : "Material Symbols Rounded"
            font.pixelSize: 42
            color: conversationBody.accent
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: conversationBody.greeting()
            font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
            font.pixelSize: conversationBody.compact ? 26 : 32
            font.weight: Font.DemiBold
            color: conversationBody.mainText
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, 520)
            horizontalAlignment: Text.AlignHCenter
            text: "What would you like to make, understand, or work through?"
            wrapMode: Text.WordWrap
            font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
            font.pixelSize: 15
            lineHeight: 1.3
            color: conversationBody.subText
        }

        Item { width: 1; height: 6 }

        // Wide: horizontal intent cards
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, 780)
            spacing: 10
            visible: !conversationBody.compact

            AssistantIntentCard {
                Layout.fillWidth: true
                theme: conversationBody.theme
                icon: "edit_note"
                title: "Make something"
                detail: "Write, shape, or refine"
                prompt: "Help me create "
                onClicked: conversationBody.intentSelected(title, prompt)
            }

            AssistantIntentCard {
                Layout.fillWidth: true
                theme: conversationBody.theme
                icon: "lightbulb"
                title: "Explore an idea"
                detail: "Think it through together"
                prompt: "I want to explore "
                onClicked: conversationBody.intentSelected(title, prompt)
            }

            AssistantIntentCard {
                Layout.fillWidth: true
                theme: conversationBody.theme
                icon: "screenshot_monitor"
                title: "Use my screen"
                detail: "Work with what is visible"
                prompt: "Help me with what is on my screen: "
                onClicked: conversationBody.intentSelected(title, prompt)
            }
        }

        // Compact: vertical intent cards
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, 400)
            spacing: 8
            visible: conversationBody.compact

            AssistantIntentCard {
                Layout.fillWidth: true
                theme: conversationBody.theme
                icon: "edit_note"
                title: "Make something"
                detail: "Write, shape, or refine"
                prompt: "Help me create "
                onClicked: conversationBody.intentSelected(title, prompt)
            }

            AssistantIntentCard {
                Layout.fillWidth: true
                theme: conversationBody.theme
                icon: "lightbulb"
                title: "Explore an idea"
                detail: "Think it through together"
                prompt: "I want to explore "
                onClicked: conversationBody.intentSelected(title, prompt)
            }

            AssistantIntentCard {
                Layout.fillWidth: true
                theme: conversationBody.theme
                icon: "screenshot_monitor"
                title: "Use my screen"
                detail: "Work with what is visible"
                prompt: "Help me with what is on my screen: "
                onClicked: conversationBody.intentSelected(title, prompt)
            }
        }
    }
}
