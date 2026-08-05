import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "../../../core/services/ai"
import "../../../core/state" as State
Item {
    id: root

    property var theme: null
    property bool clipboardContext: false
    property bool selectionContext: false
    property bool screenContext: false
    property bool historyOpen: false
    property string activeMode: "Ask"

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"
    readonly property color cardColor: theme ? theme.surfaceCard : "#111115"
    readonly property color raisedColor: theme ? theme.surfaceOverlay : "#1a1a22"
    readonly property int activeContextCount: (clipboardContext ? 1 : 0)
                                              + (selectionContext ? 1 : 0)
                                              + (screenContext ? 1 : 0)
    readonly property bool compact: width < 860

    // ── Main two-column layout
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Navigation Rail (slide in/out)
        AssistantNavigationRail {
            theme: root.theme
            historyOpen: root.historyOpen
            compact: root.compact
            activeContextCount: root.activeContextCount
            lastPrompt: ConversationService.lastUserMessage
            hasMessages: ConversationService.hasMessages
            activeMode: root.activeMode

            clipboardContext: root.clipboardContext
            selectionContext: root.selectionContext
            screenContext: root.screenContext

            onToggleClipboard: root.clipboardContext = !root.clipboardContext
            onToggleSelection: root.selectionContext = !root.selectionContext
            onToggleScreen: root.screenContext = !root.screenContext
            onNewConversation: {
                if (ConversationService.newConversation())
                    root.activeMode = "Ask";
            }
            onProviderSettingsRequested: State.GlobalStates.openImmersiveCategory("Assistant")
        }

        // ── Conversation Workspace
        Item {
            id: conversationWorkspace
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Rail toggle — always visible
            AssistantIconButton {
                id: railToggle
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 10
                z: 10
                theme: root.theme
                icon: root.historyOpen ? "left_panel_close" : "left_panel_open"
                toolTip: root.historyOpen ? "Close sidebar" : "Open sidebar"
                highlighted: root.historyOpen
                onClicked: root.historyOpen = !root.historyOpen
            }

            // ── Conversation body
            AssistantConversationBody {
                id: conversationBody
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: composer.top
                anchors.bottomMargin: 8

                theme: root.theme
                compact: root.compact
                activeMode: root.activeMode

                onIntentSelected: (mode, prompt) => {
                    root.activeMode = mode;
                    composer.setPrompt(prompt);
                }
            }

            // ── Composer — full-width soft bar
            AssistantComposer {
                id: composer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.bottomMargin: 12

                theme: root.theme
                compact: root.compact
                activeContextCount: root.activeContextCount
                activeMode: root.activeMode

                clipboardContext: root.clipboardContext
                selectionContext: root.selectionContext
                screenContext: root.screenContext

                onRemoveClipboard: root.clipboardContext = false
                onRemoveSelection: root.selectionContext = false
                onRemoveScreen: root.screenContext = false

                onPromptSubmitted: prompt => {
                    ConversationService.sendMessage(prompt);
                }
            }

        }
    }

}
