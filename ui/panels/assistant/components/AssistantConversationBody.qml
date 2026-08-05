import QtQuick
import QtQuick.Layouts

Item {
    id: conversationBody

    property var theme: null
    property bool compact: false
    property string lastPrompt: ""
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
    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: messageColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        visible: conversationBody.lastPrompt.length > 0

        Column {
            id: messageColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: conversationBody.compact ? 20 : 32
            anchors.rightMargin: conversationBody.compact ? 20 : 32
            spacing: 22

            Item { width: 1; height: 14 }

            // User message
            Rectangle {
                anchors.right: parent.right
                width: Math.min(userPromptText.implicitWidth + 36, parent.width * 0.6)
                height: userPromptText.implicitHeight + 28
                radius: 18
                color: Qt.rgba(conversationBody.accent.r, conversationBody.accent.g, conversationBody.accent.b, 0.16)

                Text {
                    id: userPromptText
                    anchors.fill: parent
                    anchors.margins: 14
                    text: conversationBody.lastPrompt
                    wrapMode: Text.WordWrap
                    font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
                    font.pixelSize: 15
                    lineHeight: 1.3
                    color: conversationBody.mainText
                }
            }

            // Assistant response
            Row {
                width: parent.width
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
                        text: "The conversation layout is ready. Once a provider is connected, responses will stream into this calm reading surface without changing the workspace around you."
                        wrapMode: Text.WordWrap
                        font.family: conversationBody.theme ? conversationBody.theme.fontMain : "Inter"
                        font.pixelSize: 15
                        lineHeight: 1.35
                        color: conversationBody.subText
                    }
                }
            }
        }
    }

    // Empty state: greeting + intent cards
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        width: parent.width - (conversationBody.compact ? 40 : 64)
        spacing: 18
        visible: conversationBody.lastPrompt.length === 0

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
