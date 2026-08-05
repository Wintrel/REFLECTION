import QtQuick
import QtQuick.Layouts
import "../../../../core/services/ai"
import "../../../../core/services/system" as Sys

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

    function parseMarkdown(text) {
        var parts = text.split("```");
        var result = [];
        for (var i = 0; i < parts.length; i++) {
            var isCode = i % 2 !== 0; // Odd indices are inside code blocks
            var blockContent = parts[i];
            
            if (isCode) {
                var firstNewline = blockContent.indexOf("\n");
                var lang = "";
                if (firstNewline !== -1 && firstNewline < 20) {
                    lang = blockContent.substring(0, firstNewline).trim();
                    blockContent = blockContent.substring(firstNewline + 1);
                }
                if (blockContent.endsWith("\n")) {
                    blockContent = blockContent.substring(0, blockContent.length - 1);
                }
                result.push({ isCode: true, language: lang, content: blockContent });
            } else {
                if (blockContent.length > 0 || parts.length === 1) {
                    result.push({ isCode: false, language: "", content: blockContent });
                }
            }
        }
        return result;
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
            required property int index
            required property string role
            required property string text
            required property string status

            property bool copied: false
            readonly property bool canRegenerate: ConversationService.revision >= 0
                && ConversationService.canRegenerateResponse(messageDelegate.index)

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

                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Repeater {
                            model: conversationBody.parseMarkdown(messageDelegate.text)
                            
                            delegate: Column {
                                width: parent.width
                                spacing: 0
                                
                                // Standard Text Block.
                                Text {
                                    visible: !modelData.isCode
                                    height: visible ? implicitHeight : 0
                                    width: parent.width
                                    text: modelData.content
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
                                
                                // Code Block
                                Rectangle {
                                    visible: modelData.isCode
                                    height: visible ? (codeColumn.implicitHeight + 16) : 0
                                    width: parent.width
                                    radius: 12
                                    color: conversationBody.theme ? conversationBody.theme.surfaceCard : "#111115"
                                    border.width: 1
                                    border.color: Qt.rgba(conversationBody.mainText.r, conversationBody.mainText.g, conversationBody.mainText.b, 0.05)
                                    clip: true

                                    property bool codeCopied: false

                                    ColumnLayout {
                                        id: codeColumn
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 4
                                        visible: parent.visible

                                        // Header
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 4
                                            Layout.rightMargin: 4
                                            
                                            Text {
                                                text: (modelData.language && modelData.language.length > 0) ? modelData.language : "Code"
                                                font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: conversationBody.mutedText
                                                Layout.fillWidth: true
                                            }

                                            // Copy Button
                                            Rectangle {
                                                width: 26
                                                height: 26
                                                radius: 6
                                                color: copyMa.containsMouse ? Qt.rgba(conversationBody.mainText.r, conversationBody.mainText.g, conversationBody.mainText.b, 0.1) : "transparent"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: parent.parent.parent.codeCopied ? "check" : "content_copy"
                                                    font.family: conversationBody.theme ? conversationBody.theme.fontIcon : "Material Symbols Rounded"
                                                    font.pixelSize: 14
                                                    color: parent.parent.parent.codeCopied ? conversationBody.accent : conversationBody.subText
                                                }

                                                MouseArea {
                                                    id: copyMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (modelData.content) {
                                                            Sys.ClipboardService.setText(modelData.content);
                                                            parent.parent.parent.codeCopied = true;
                                                            copyTimer.restart();
                                                        }
                                                    }
                                                }
                                                
                                                Timer {
                                                    id: copyTimer
                                                    interval: 2000
                                                    onTriggered: parent.parent.parent.parent.codeCopied = false
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 1
                                            color: Qt.rgba(conversationBody.mainText.r, conversationBody.mainText.g, conversationBody.mainText.b, 0.05)
                                        }

                                        // Code Content
                                        Text {
                                            Layout.fillWidth: true
                                            Layout.topMargin: 4
                                            Layout.leftMargin: 4
                                            Layout.rightMargin: 4
                                            Layout.bottomMargin: 4
                                            text: modelData.content
                                            wrapMode: Text.WrapAnywhere
                                            font.family: "Monospace"
                                            font.pixelSize: 13
                                            lineHeight: 1.4
                                            color: conversationBody.subText
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 2
                        visible: messageDelegate.text.length > 0
                            || messageDelegate.status === "streaming"
                        height: visible ? 30 : 0
                        opacity: 0.76

                        AssistantIconButton {
                            width: 30
                            height: 30
                            radius: 9
                            theme: conversationBody.theme
                            icon: messageDelegate.copied ? "check" : "content_copy"
                            toolTip: messageDelegate.copied ? "Copied" : "Copy response"
                            visible: messageDelegate.text.length > 0 && !ConversationService.isCompacting
                            onClicked: {
                                if (ConversationService.copyMessage(messageDelegate.index)) {
                                    messageDelegate.copied = true;
                                    copiedReset.restart();
                                }
                            }
                        }

                        AssistantIconButton {
                            width: 30
                            height: 30
                            radius: 9
                            theme: conversationBody.theme
                            icon: "refresh"
                            toolTip: "Regenerate response"
                            visible: messageDelegate.canRegenerate
                            onClicked: ConversationService.regenerateResponse(messageDelegate.index)
                        }

                        AssistantIconButton {
                            width: 30
                            height: 30
                            radius: 9
                            theme: conversationBody.theme
                            icon: "stop_circle"
                            toolTip: "Stop generating"
                            highlighted: true
                            visible: messageDelegate.status === "streaming"
                                && ConversationService.isGenerating
                            onClicked: ConversationService.stopGeneration()
                        }
                    }
                }
            }

            Timer {
                id: copiedReset
                interval: 1600
                onTriggered: messageDelegate.copied = false
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
