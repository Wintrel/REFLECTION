import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../core/services/ai"

Rectangle {
    id: providerCard

    required property string providerId
    required property string providerName
    property var theme: null

    readonly property bool configured: providerId === "groq"
        ? ConversationService.groqConfigured : ConversationService.geminiConfigured
    readonly property string currentModel: providerId === "groq"
        ? ConversationService.groqModel : ConversationService.geminiModel

    property string modelDraft: ""
    property string keyDraft: ""
    property bool revealKey: false
    property bool confirmingRemove: false
    property string feedback: ""

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"

    function resetDrafts() {
        modelDraft = currentModel;
        keyDraft = "";
        revealKey = false;
        confirmingRemove = false;
        feedback = "";
    }

    function save() {
        if (ConversationService.saveProviderSettings(providerId, modelDraft, keyDraft)) {
            keyDraft = "";
            revealKey = false;
            feedback = "Saved";
            feedbackTimer.restart();
        } else {
            feedback = ConversationService.settingsError || "Could not save";
        }
    }

    implicitWidth: 480
    implicitHeight: 240
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight
    radius: 17
    color: Qt.rgba(255, 255, 255, 0.027)
    border.width: 1
    border.color: Qt.rgba(255, 255, 255, 0.065)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            spacing: 9

            Rectangle {
                Layout.preferredWidth: 9
                Layout.preferredHeight: 9
                radius: 5
                color: providerCard.configured ? providerCard.accent : providerCard.mutedText
            }

            Text {
                Layout.fillWidth: true
                text: providerCard.providerName
                font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: providerCard.mainText
            }

            Text {
                text: providerCard.feedback.length > 0
                    ? providerCard.feedback
                    : (providerCard.configured ? "Key configured" : "Key required")
                elide: Text.ElideRight
                font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                font.pixelSize: 10
                color: providerCard.feedback === "Saved" || providerCard.configured
                    ? providerCard.accent : providerCard.mutedText
            }
        }

        Text {
            text: "MODEL"
            font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
            font.pixelSize: 9
            font.letterSpacing: 1.1
            font.weight: Font.Bold
            color: providerCard.mutedText
        }

        TextField {
            id: modelField
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            text: providerCard.modelDraft
            selectByMouse: true
            leftPadding: 12
            rightPadding: 12
            color: providerCard.mainText
            selectionColor: providerCard.accent
            placeholderText: providerCard.providerId === "groq"
                ? "llama-3.1-8b-instant" : "gemini model name"
            placeholderTextColor: providerCard.mutedText
            font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
            font.pixelSize: 11
            onTextEdited: providerCard.modelDraft = text
            background: Rectangle {
                radius: 11
                color: Qt.rgba(255, 255, 255, 0.025)
                border.width: 1
                border.color: modelField.activeFocus
                    ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.5)
                    : Qt.rgba(255, 255, 255, 0.07)
            }
        }

        Text {
            text: "API KEY"
            font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
            font.pixelSize: 9
            font.letterSpacing: 1.1
            font.weight: Font.Bold
            color: providerCard.mutedText
        }

        TextField {
            id: keyField
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            text: providerCard.keyDraft
            echoMode: providerCard.revealKey ? TextInput.Normal : TextInput.Password
            passwordCharacter: "•"
            selectByMouse: true
            leftPadding: 12
            rightPadding: 42
            color: providerCard.mainText
            selectionColor: providerCard.accent
            placeholderText: providerCard.configured
                ? "Stored key — enter a replacement"
                : "Enter API key"
            placeholderTextColor: providerCard.mutedText
            font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
            font.pixelSize: 11
            onTextEdited: providerCard.keyDraft = text
            background: Rectangle {
                radius: 11
                color: Qt.rgba(255, 255, 255, 0.025)
                border.width: 1
                border.color: keyField.activeFocus
                    ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.5)
                    : Qt.rgba(255, 255, 255, 0.07)
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: providerCard.revealKey ? "visibility_off" : "visibility"
                font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: providerCard.mutedText

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7
                    enabled: providerCard.keyDraft.length > 0
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: providerCard.revealKey = !providerCard.revealKey
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 7

            Rectangle {
                Layout.preferredWidth: removeLabel.implicitWidth + 18
                Layout.preferredHeight: 30
                radius: 9
                visible: providerCard.configured
                color: providerCard.confirmingRemove
                    ? Qt.rgba(1, 0.25, 0.25, 0.14) : "transparent"

                Text {
                    id: removeLabel
                    anchors.centerIn: parent
                    text: providerCard.confirmingRemove ? "Confirm removal" : "Remove key"
                    font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: providerCard.confirmingRemove ? "#ff8585" : providerCard.mutedText
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !ConversationService.isGenerating
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (!providerCard.confirmingRemove) {
                            providerCard.confirmingRemove = true;
                        } else if (ConversationService.removeProviderKey(providerCard.providerId)) {
                            providerCard.confirmingRemove = false;
                            providerCard.feedback = "Key removed";
                            feedbackTimer.restart();
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 74
                Layout.preferredHeight: 30
                radius: 9
                color: saveMouse.enabled
                    ? providerCard.accent
                    : Qt.rgba(providerCard.subText.r, providerCard.subText.g, providerCard.subText.b, 0.10)

                Text {
                    anchors.centerIn: parent
                    text: "Save"
                    font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: saveMouse.enabled
                        ? (providerCard.theme ? providerCard.theme.bgBase : "#101014")
                        : providerCard.mutedText
                }

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    enabled: providerCard.modelDraft.trim().length > 0
                        && !ConversationService.isGenerating
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: providerCard.save()
                }
            }
        }
    }

    Timer {
        id: feedbackTimer
        interval: 2200
        onTriggered: providerCard.feedback = ""
    }

    Component.onCompleted: resetDrafts()
}
