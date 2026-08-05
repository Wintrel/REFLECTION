import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../core/services/ai"
import "../../control_center/components" as CC

Rectangle {
    id: providerCard

    required property string providerId
    required property string providerName
    property var theme: null

    readonly property bool isCurrentProvider: ConversationService.providerId === providerId
    readonly property bool configured: providerId === "ollama"
        ? ConversationService.ollamaConfigured : (providerId === "groq"
        ? ConversationService.groqConfigured : ConversationService.geminiConfigured)
    readonly property string currentModel: providerId === "ollama"
        ? ConversationService.ollamaModel : (providerId === "groq"
        ? ConversationService.groqModel : ConversationService.geminiModel)

    property string modelDraft: ""
    property string keyDraft: ""
    property real temperatureDraft: 0.8
    property int numCtxDraft: 2048
    property string systemPromptDraft: ""
    property bool revealKey: false
    property bool confirmingRemove: false
    property string feedback: ""

    onProviderIdChanged: resetDrafts()

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"

    function resetDrafts() {
        modelDraft = currentModel;
        keyDraft = providerId === "ollama" ? ConversationService.ollamaUrl : "";
        temperatureDraft = ConversationService.ollamaTemperature;
        numCtxDraft = ConversationService.ollamaNumCtx;
        systemPromptDraft = ConversationService.ollamaSystemPrompt;
        revealKey = false;
        confirmingRemove = false;
        feedback = "";
    }

    function save() {
        var extra = providerId === "ollama" ? {
            temperature: temperatureDraft,
            numCtx: numCtxDraft,
            systemPrompt: systemPromptDraft
        } : null;
        if (ConversationService.saveProviderSettings(providerId, modelDraft, keyDraft, extra)) {
            keyDraft = providerId === "ollama" ? ConversationService.ollamaUrl : "";
            revealKey = false;
            feedback = "Saved";
            feedbackTimer.restart();
        } else {
            feedback = ConversationService.settingsError || "Could not save";
        }
    }

    Layout.fillWidth: true
    implicitHeight: cardContent.implicitHeight + 36
    radius: 16
    color: theme ? Qt.rgba(theme.surfaceCard.r, theme.surfaceCard.g, theme.surfaceCard.b, 0.68) : Qt.rgba(0.08, 0.08, 0.10, 0.68)
    border.width: 1
    border.color: isCurrentProvider
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.35)
        : Qt.rgba(255, 255, 255, 0.06)

    Behavior on border.color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        id: cardContent
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        // Top Header Row inside Card
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 10
                color: isCurrentProvider
                    ? Qt.rgba(accent.r, accent.g, accent.b, 0.18)
                    : Qt.rgba(255, 255, 255, 0.035)

                Text {
                    anchors.centerIn: parent
                    text: providerCard.providerId === "gemini" ? "auto_awesome" : (providerCard.providerId === "groq" ? "bolt" : "terminal")
                    font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 19
                    color: providerCard.isCurrentProvider ? providerCard.accent : providerCard.subText
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    spacing: 7
                    Text {
                        text: providerCard.providerName
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: providerCard.mainText
                    }

                    Rectangle {
                        Layout.preferredWidth: 7
                        Layout.preferredHeight: 7
                        radius: 4
                        color: providerCard.configured ? providerCard.accent : (providerCard.providerId === "ollama" ? "#ff7373" : providerCard.mutedText)
                    }
                }

                Text {
                    text: providerCard.feedback.length > 0
                        ? providerCard.feedback
                        : (providerCard.configured
                            ? (providerCard.providerId === "ollama" ? "Local server ready" : "API key configured")
                            : (providerCard.providerId === "ollama" ? "Server URL required" : "API key required"))
                    font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: providerCard.feedback === "Saved" || providerCard.configured
                        ? providerCard.subText : providerCard.mutedText
                }
            }

            // Active Provider Badge / Toggle Button
            Rectangle {
                Layout.preferredHeight: 30
                implicitWidth: activeRow.implicitWidth + 20
                radius: 8
                color: providerCard.isCurrentProvider
                    ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.18)
                    : (activeMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.06) : Qt.rgba(255, 255, 255, 0.025))
                border.width: 1
                border.color: providerCard.isCurrentProvider
                    ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.35)
                    : Qt.rgba(255, 255, 255, 0.06)

                RowLayout {
                    id: activeRow
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        visible: providerCard.isCurrentProvider
                        text: "check"
                        font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: providerCard.accent
                    }

                    Text {
                        text: providerCard.isCurrentProvider ? "Active Backend" : "Set Active"
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        font.weight: providerCard.isCurrentProvider ? Font.DemiBold : Font.Normal
                        color: providerCard.isCurrentProvider ? providerCard.accent : providerCard.subText
                    }
                }

                MouseArea {
                    id: activeMouse
                    anchors.fill: parent
                    enabled: !providerCard.isCurrentProvider && providerCard.configured && !ConversationService.isGenerating
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: ConversationService.setProvider(providerCard.providerId)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(255, 255, 255, 0.045)
        }

        // Model Field Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                spacing: 6
                Text {
                    text: "psychology"
                    font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 14
                    color: providerCard.mutedText
                }
                Text {
                    text: "MODEL SELECTION"
                    font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                    font.pixelSize: 9
                    font.letterSpacing: 1.1
                    font.weight: Font.Bold
                    color: providerCard.mutedText
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                spacing: 8

                TextField {
                    id: modelField
                    visible: providerCard.providerId !== "ollama"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: providerCard.modelDraft
                    selectByMouse: true
                    leftPadding: 12
                    rightPadding: 12
                    color: providerCard.mainText
                    selectionColor: providerCard.accent
                    placeholderText: providerCard.providerId === "groq"
                        ? "llama-3.1-8b-instant" : "gemini-2.5-flash"
                    placeholderTextColor: providerCard.mutedText
                    font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    onTextEdited: providerCard.modelDraft = text
                    background: Rectangle {
                        radius: 10
                        color: Qt.rgba(255, 255, 255, 0.025)
                        border.width: 1
                        border.color: modelField.activeFocus
                            ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.45)
                            : Qt.rgba(255, 255, 255, 0.07)
                    }
                }

                ComboBox {
                    id: ollamaModelCombo
                    visible: providerCard.providerId === "ollama"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: ConversationService.availableOllamaModels
                    editable: true
                    editText: providerCard.modelDraft
                    onActivated: providerCard.modelDraft = currentText
                    onAccepted: providerCard.modelDraft = editText

                    background: Rectangle {
                        radius: 10
                        color: Qt.rgba(255, 255, 255, 0.025)
                        border.width: 1
                        border.color: ollamaModelCombo.activeFocus
                            ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.45)
                            : Qt.rgba(255, 255, 255, 0.07)
                    }

                    contentItem: TextField {
                        text: ollamaModelCombo.editText
                        color: providerCard.mainText
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                        background: null
                        onTextEdited: {
                            ollamaModelCombo.editText = text;
                            providerCard.modelDraft = text;
                        }
                    }
                }

                Rectangle {
                    visible: providerCard.providerId === "ollama"
                    Layout.preferredWidth: 38
                    Layout.fillHeight: true
                    radius: 10
                    color: refreshMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.055) : Qt.rgba(255, 255, 255, 0.025)
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.07)

                    Text {
                        anchors.centerIn: parent
                        text: "refresh"
                        font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 17
                        color: refreshMouse.containsMouse ? providerCard.accent : providerCard.subText
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AiDaemonService.fetchOllamaModels()
                    }
                }
            }
        }

        // Key / Server URL Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                spacing: 6
                Text {
                    text: providerCard.providerId === "ollama" ? "dns" : "key"
                    font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 14
                    color: providerCard.mutedText
                }
                Text {
                    text: providerCard.providerId === "ollama" ? "SERVER URL" : "API KEY"
                    font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                    font.pixelSize: 9
                    font.letterSpacing: 1.1
                    font.weight: Font.Bold
                    color: providerCard.mutedText
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 38

                TextField {
                    id: keyField
                    anchors.fill: parent
                    text: providerCard.keyDraft
                    echoMode: providerCard.revealKey || providerCard.providerId === "ollama" ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "•"
                    selectByMouse: true
                    leftPadding: 12
                    rightPadding: 42
                    color: providerCard.mainText
                    selectionColor: providerCard.accent
                    placeholderText: providerCard.providerId === "ollama"
                        ? "http://127.0.0.1:11434"
                        : (providerCard.configured
                            ? "Stored key — enter a replacement"
                            : "Enter API key")
                    placeholderTextColor: providerCard.mutedText
                    font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    onTextEdited: providerCard.keyDraft = text
                    background: Rectangle {
                        radius: 10
                        color: Qt.rgba(255, 255, 255, 0.025)
                        border.width: 1
                        border.color: keyField.activeFocus
                            ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.45)
                            : Qt.rgba(255, 255, 255, 0.07)
                    }
                }

                Text {
                    visible: providerCard.providerId !== "ollama"
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
        }

        // Ollama Advanced Parameters (Context size, Temperature, System Prompt)
        ColumnLayout {
            Layout.fillWidth: true
            visible: providerCard.providerId === "ollama"
            spacing: 12

            // Context Memory Budget Slider (ThickSlider)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    spacing: 6
                    Text {
                        text: "memory"
                        font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: providerCard.mutedText
                    }
                    Text {
                        text: "CONTEXT MEMORY BUDGET"
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 9
                        font.letterSpacing: 1.1
                        font.weight: Font.Bold
                        color: providerCard.mutedText
                    }
                }

                CC.ThickSlider {
                    Layout.fillWidth: true
                    theme: providerCard.theme
                    icon: "memory"
                    value: Math.max(0, Math.min(100, ((providerCard.numCtxDraft - 2048) / (16384 - 2048)) * 100))
                    valueText: providerCard.numCtxDraft + " tokens"

                    onValueChangedByUser: function(newVal) {
                        var step = 1024;
                        var raw = 2048 + (newVal / 100) * (16384 - 2048);
                        var rounded = Math.round(raw / step) * step;
                        providerCard.numCtxDraft = Math.max(2048, Math.min(16384, rounded));
                    }
                }
            }

            // Temperature Slider (ThickSlider)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    spacing: 6
                    Text {
                        text: "thermostat"
                        font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: providerCard.mutedText
                    }
                    Text {
                        text: "SAMPLING TEMPERATURE"
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 9
                        font.letterSpacing: 1.1
                        font.weight: Font.Bold
                        color: providerCard.mutedText
                    }
                }

                CC.ThickSlider {
                    Layout.fillWidth: true
                    theme: providerCard.theme
                    icon: "thermostat"
                    value: Math.max(0, Math.min(100, providerCard.temperatureDraft * 100))
                    valueText: Number(providerCard.temperatureDraft).toFixed(2)

                    onValueChangedByUser: function(newVal) {
                        var raw = (newVal / 100);
                        var rounded = Math.round(raw / 0.05) * 0.05;
                        providerCard.temperatureDraft = Math.max(0.0, Math.min(1.0, rounded));
                    }
                }
            }

            // System Prompt TextArea
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    spacing: 6
                    Text {
                        text: "description"
                        font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: providerCard.mutedText
                    }
                    Text {
                        text: "SYSTEM INSTRUCTIONS / PROMPT"
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 9
                        font.letterSpacing: 1.1
                        font.weight: Font.Bold
                        color: providerCard.mutedText
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    clip: true

                    TextArea {
                        text: providerCard.systemPromptDraft
                        placeholderText: "Override default instructions (optional)"
                        placeholderTextColor: providerCard.mutedText
                        color: providerCard.mainText
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        wrapMode: TextArea.Wrap
                        onTextChanged: providerCard.systemPromptDraft = text
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 10
                        bottomPadding: 10
                        background: Rectangle {
                            radius: 10
                            color: Qt.rgba(255, 255, 255, 0.025)
                            border.width: 1
                            border.color: parent.activeFocus
                                ? Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.45)
                                : Qt.rgba(255, 255, 255, 0.07)
                        }
                    }
                }
            }
        }

        // Action Buttons Row (Remove & Save)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            spacing: 8

            Rectangle {
                Layout.preferredWidth: removeLabel.implicitWidth + 24
                Layout.preferredHeight: 32
                radius: 9
                visible: providerCard.configured && providerCard.providerId !== "ollama"
                color: providerCard.confirmingRemove
                    ? Qt.rgba(1, 0.25, 0.25, 0.16)
                    : (removeMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(255, 255, 255, 0.025))
                border.width: 1
                border.color: providerCard.confirmingRemove
                    ? Qt.rgba(1, 0.35, 0.35, 0.35)
                    : Qt.rgba(255, 255, 255, 0.06)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: "delete_outline"
                        font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 15
                        color: providerCard.confirmingRemove ? "#ff7777" : providerCard.mutedText
                    }

                    Text {
                        id: removeLabel
                        text: providerCard.confirmingRemove ? "Confirm removal" : "Remove key"
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: providerCard.confirmingRemove ? "#ff7777" : providerCard.subText
                    }
                }

                MouseArea {
                    id: removeMouse
                    anchors.fill: parent
                    enabled: !ConversationService.isGenerating
                    hoverEnabled: true
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
                Layout.preferredWidth: saveRow.implicitWidth + 24
                Layout.preferredHeight: 32
                radius: 9
                color: saveMouse.enabled
                    ? (saveMouse.containsMouse
                        ? providerCard.accent
                        : Qt.rgba(providerCard.accent.r, providerCard.accent.g, providerCard.accent.b, 0.85))
                    : Qt.rgba(255, 255, 255, 0.04)

                RowLayout {
                    id: saveRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "save"
                        font.family: providerCard.theme ? providerCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 15
                        color: saveMouse.enabled
                            ? (providerCard.theme ? providerCard.theme.bgBase : "#101014")
                            : providerCard.mutedText
                    }

                    Text {
                        text: "Save Changes"
                        font.family: providerCard.theme ? providerCard.theme.fontMain : "Inter"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: saveMouse.enabled
                            ? (providerCard.theme ? providerCard.theme.bgBase : "#101014")
                            : providerCard.mutedText
                    }
                }

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    enabled: providerCard.modelDraft.trim().length > 0
                        && !ConversationService.isGenerating
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: providerCard.save()
                }
            }
        }
    }

    Timer {
        id: feedbackTimer
        interval: 2400
        onTriggered: providerCard.feedback = ""
    }

    Component.onCompleted: resetDrafts()
}
