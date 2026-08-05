import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../core/services/ai"

Rectangle {
    id: composer

    property var theme: null
    property int activeContextCount: 0
    property string activeMode: "Ask"
    property bool compact: false

    property bool clipboardContext: false
    property bool selectionContext: false
    property bool screenContext: false

    signal removeClipboard()
    signal removeSelection()
    signal removeScreen()

    signal promptSubmitted(string prompt)

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"
    readonly property color raisedColor: theme ? theme.surfaceOverlay : "#1a1a22"

    function setPrompt(prompt) {
        composerInput.text = prompt;
        composerInput.forceActiveFocus();
    }

    function submitPrompt() {
        var prompt = composerInput.text.trim();
        if (prompt.length === 0 || ConversationService.isGenerating)
            return;
        composer.promptSubmitted(prompt);
        composerInput.text = "";
    }

    height: activeContextCount > 0 ? 140 : 110
    radius: 20
    color: raisedColor
    border.width: 1
    border.color: composerInput.activeFocus
        ? Qt.rgba(accent.r, accent.g, accent.b, 0.48)
        : Qt.rgba(mainText.r, mainText.g, mainText.b, 0.06)

    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // Context chips row
    Flow {
        id: contextChips
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: 12
        height: composer.activeContextCount > 0 ? 30 : 0
        spacing: 7
        visible: composer.activeContextCount > 0

        AssistantContextChip {
            visible: composer.clipboardContext
            theme: composer.theme
            icon: "content_paste"
            label: "Clipboard"
            onRemoved: composer.removeClipboard()
        }

        AssistantContextChip {
            visible: composer.selectionContext
            theme: composer.theme
            icon: "text_select_start"
            label: "Selected text"
            onRemoved: composer.removeSelection()
        }

        AssistantContextChip {
            visible: composer.screenContext
            theme: composer.theme
            icon: "screenshot_monitor"
            label: "Current screen"
            onRemoved: composer.removeScreen()
        }
    }

    TextArea {
        id: composerInput
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: composerActions.top
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: composer.activeContextCount > 0 ? 48 : 14
        padding: 0
        background: null
        placeholderText: composer.activeMode === "Ask" ? "Ask Reflection…" : composer.activeMode + " with Reflection…"
        placeholderTextColor: composer.mutedText
        color: composer.mainText
        selectionColor: composer.accent
        selectedTextColor: composer.theme ? composer.theme.bgBase : "#101014"
        font.family: composer.theme ? composer.theme.fontMain : "Inter"
        font.pixelSize: 15
        wrapMode: TextEdit.Wrap
        selectByMouse: true

        Keys.onReturnPressed: event => {
            if (!(event.modifiers & Qt.ShiftModifier) && !ConversationService.isGenerating) {
                composer.submitPrompt();
                event.accepted = true;
            }
        }
    }

    RowLayout {
        id: composerActions
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 8
        height: 40
        spacing: 6

        AssistantIconButton {
            theme: composer.theme
            icon: "add"
            toolTip: "Attach a file"
        }

        Text {
            Layout.fillWidth: true
            visible: !composer.compact
            text: "Enter to send  ·  Shift+Enter for a new line"
            horizontalAlignment: Text.AlignRight
            font.family: composer.theme ? composer.theme.fontMain : "Inter"
            font.pixelSize: 11
            color: composer.mutedText
        }

        Item {
            Layout.fillWidth: true
            visible: composer.compact
        }

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 13
            color: composerInput.text.trim().length > 0
                    && !ConversationService.isGenerating
                ? composer.accent
                : Qt.rgba(composer.subText.r, composer.subText.g, composer.subText.b, 0.10)

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "arrow_upward"
                font.family: composer.theme ? composer.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 20
                color: composerInput.text.trim().length > 0
                        && !ConversationService.isGenerating
                    ? (composer.theme ? composer.theme.bgBase : "#101014")
                    : composer.mutedText
            }

            MouseArea {
                anchors.fill: parent
                enabled: composerInput.text.trim().length > 0 && !ConversationService.isGenerating
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: composer.submitPrompt()
            }
        }
    }
}
