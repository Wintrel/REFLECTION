import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../../core/services/ai"

Rectangle {
    id: navigationRail

    property var theme: null
    property bool historyOpen: false
    property bool compact: false
    property int activeContextCount: 0
    property bool hasMessages: false
    property string lastPrompt: ""
    property string activeMode: "Ask"

    property bool clipboardContext: false
    property bool selectionContext: false
    property bool screenContext: false
    property bool providerMenuOpen: false
    property string pendingDeleteId: ""
    property string searchText: ""
    property string contextConversationId: ""
    property string renamingConversationId: ""
    property string renameDraft: ""

    signal toggleClipboard()
    signal toggleSelection()
    signal toggleScreen()
    signal newConversation()
    signal providerSettingsRequested()

    readonly property color accent: theme ? theme.accentPrimary : "#8c8cff"
    readonly property color mainText: theme ? theme.textMain : "#ffffff"
    readonly property color subText: theme ? theme.textSub : "#a6adc8"
    readonly property color mutedText: theme ? theme.textMuted : "#707080"

    function relativeTime(isoDate) {
        var timestamp = Date.parse(isoDate);
        if (isNaN(timestamp))
            return "";
        var elapsed = Math.max(0, Date.now() - timestamp);
        var minutes = Math.floor(elapsed / 60000);
        if (minutes < 1) return "now";
        if (minutes < 60) return minutes + "m";
        var hours = Math.floor(minutes / 60);
        if (hours < 24) return hours + "h";
        var days = Math.floor(hours / 24);
        return days < 7 ? days + "d" : new Date(timestamp).toLocaleDateString(Qt.locale(), "dd MMM");
    }

    function rebuildFilteredConversations() {
        filteredConversationModel.clear();
        var query = searchText.trim().toLowerCase();
        for (var i = 0; i < ConversationService.conversations.count; i++) {
            var conversation = ConversationService.conversations.get(i);
            var searchable = (conversation.title + " " + conversation.preview + " " + conversation.provider).toLowerCase();
            if (query.length === 0 || searchable.indexOf(query) !== -1) {
                filteredConversationModel.append({
                    conversationId: conversation.conversationId,
                    title: conversation.title,
                    preview: conversation.preview,
                    updatedAt: conversation.updatedAt,
                    provider: conversation.provider
                });
            }
        }
    }

    function beginRename(conversationId, currentTitle) {
        pendingDeleteId = "";
        contextConversationId = "";
        renamingConversationId = conversationId;
        renameDraft = currentTitle;
    }

    function commitRename() {
        var conversationId = renamingConversationId;
        if (conversationId.length === 0)
            return;
        if (ConversationService.renameConversation(conversationId, renameDraft))
            renamingConversationId = "";
    }

    function cancelRename() {
        renamingConversationId = "";
        renameDraft = "";
    }

    onSearchTextChanged: rebuildFilteredConversations()

    onHistoryOpenChanged: {
        if (!historyOpen)
            providerMenuOpen = false;
    }

    ListModel { id: filteredConversationModel }

    Connections {
        target: ConversationService
        function onConversationsRevisionChanged() { navigationRail.rebuildFilteredConversations(); }
    }

    Component.onCompleted: rebuildFilteredConversations()

    Layout.preferredWidth: historyOpen ? (compact ? Math.min(280, parent.width - 48) : 300) : 0
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
                z: 2
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8

                Rectangle {
                    width: 7; height: 7; radius: 4
                    color: ConversationService.providerConfigured ? navigationRail.accent : navigationRail.mutedText
                    opacity: 0.75
                }

                Text {
                    Layout.fillWidth: true
                    text: ConversationService.providerConfigured
                        ? ConversationService.providerName + " · " + ConversationService.providerModel
                        : ConversationService.providerName + " needs an API key"
                    elide: Text.ElideRight
                    font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    color: navigationRail.subText
                }

                Text {
                    text: "settings"
                    font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 17
                    color: navigationRail.mutedText

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: navigationRail.providerSettingsRequested()
                    }
                }

                Text {
                    text: navigationRail.providerMenuOpen ? "expand_less" : "expand_more"
                    font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 18
                    color: navigationRail.mutedText
                }
            }

            MouseArea {
                id: providerRailMouse
                z: 1
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: navigationRail.providerMenuOpen = !navigationRail.providerMenuOpen
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: navigationRail.providerMenuOpen ? 174 : 0
            radius: 15
            clip: true
            opacity: navigationRail.providerMenuOpen ? 1 : 0
            color: Qt.rgba(255, 255, 255, 0.025)
            border.width: navigationRail.providerMenuOpen ? 1 : 0
            border.color: Qt.rgba(255, 255, 255, 0.055)

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
            }
            Behavior on opacity { NumberAnimation { duration: 140 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 4

                Repeater {
                    model: [
                        { providerId: "ollama", name: "Ollama", modelName: ConversationService.ollamaModel, configured: ConversationService.ollamaConfigured },
                        { providerId: "groq", name: "Groq", modelName: ConversationService.groqModel, configured: ConversationService.groqConfigured },
                        { providerId: "gemini", name: "Gemini", modelName: ConversationService.geminiModel, configured: ConversationService.geminiConfigured }
                    ]

                    delegate: Rectangle {
                        id: providerChoice
                        required property var modelData
                        readonly property bool selected: ConversationService.providerId === modelData.providerId
                        readonly property bool selectable: modelData.configured && !ConversationService.isGenerating

                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        radius: 11
                        color: selected
                            ? Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.14)
                            : (choiceMouse.containsMouse && selectable
                                ? Qt.rgba(255, 255, 255, 0.055)
                                : "transparent")

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 9

                            Rectangle {
                                Layout.preferredWidth: 7
                                Layout.preferredHeight: 7
                                radius: 4
                                color: providerChoice.modelData.configured
                                    ? navigationRail.accent
                                    : navigationRail.mutedText
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: providerChoice.modelData.name
                                    font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    color: providerChoice.modelData.configured
                                        ? navigationRail.mainText
                                        : navigationRail.mutedText
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: providerChoice.modelData.configured
                                        ? providerChoice.modelData.modelName
                                        : "API key not configured"
                                    elide: Text.ElideRight
                                    font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                                    font.pixelSize: 10
                                    color: navigationRail.subText
                                }
                            }

                            Text {
                                text: providerChoice.selected ? "check" : (providerChoice.modelData.configured ? "" : "lock")
                                font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 17
                                color: providerChoice.selected ? navigationRail.accent : navigationRail.mutedText
                            }
                        }

                        MouseArea {
                            id: choiceMouse
                            anchors.fill: parent
                            enabled: providerChoice.selectable
                            hoverEnabled: true
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (ConversationService.setProvider(providerChoice.modelData.providerId))
                                    navigationRail.providerMenuOpen = false;
                            }
                        }
                    }
                }
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

        // Start a fresh local conversation
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
                    text: "add_comment"
                    font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 19
                    color: navigationRail.subText
                }

                Text {
                    Layout.fillWidth: true
                    text: "New conversation"
                    font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                    font.pixelSize: 13
                    color: navigationRail.mutedText
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: navigationRail.newConversation()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: 13
            color: Qt.rgba(255, 255, 255, 0.03)
            border.width: searchInput.activeFocus ? 1 : 0
            border.color: Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.35)

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 11
                anchors.verticalCenter: parent.verticalCenter
                text: "search"
                font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 17
                color: navigationRail.mutedText
            }

            TextField {
                id: searchInput
                anchors.left: parent.left
                anchors.leftMargin: 36
                anchors.right: clearSearch.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                padding: 0
                background: null
                placeholderText: "Search conversations"
                placeholderTextColor: navigationRail.mutedText
                color: navigationRail.mainText
                font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                font.pixelSize: 11
                onTextChanged: navigationRail.searchText = text
            }

            Text {
                id: clearSearch
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: searchInput.text.length > 0
                text: "close"
                font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 15
                color: navigationRail.mutedText

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: searchInput.clear()
                }
            }
        }

        ListView {
            id: conversationList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 76
            model: filteredConversationModel
            spacing: 7
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: conversationCard
                required property string conversationId
                required property string title
                required property string preview
                required property string updatedAt
                required property string provider

                readonly property bool selected: conversationId === ConversationService.activeConversationId
                readonly property bool confirmingDelete: navigationRail.pendingDeleteId === conversationId
                readonly property bool contextOpen: navigationRail.contextConversationId === conversationId
                readonly property bool renaming: navigationRail.renamingConversationId === conversationId

                width: conversationList.width
                height: 66
                radius: 15
                color: selected
                    ? Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.12)
                    : (conversationMouse.containsMouse
                        ? Qt.rgba(255, 255, 255, 0.05)
                        : Qt.rgba(255, 255, 255, 0.025))
                border.width: selected ? 1 : 0
                border.color: Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.22)

                Behavior on color { ColorAnimation { duration: 130 } }

                MouseArea {
                    id: conversationMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: ConversationService.isGenerating ? Qt.ArrowCursor : Qt.PointingHandCursor
                    enabled: !ConversationService.isGenerating
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            navigationRail.pendingDeleteId = "";
                            navigationRail.contextConversationId = conversationCard.contextOpen
                                ? ""
                                : conversationCard.conversationId;
                        } else {
                            navigationRail.contextConversationId = "";
                            navigationRail.pendingDeleteId = "";
                            ConversationService.selectConversation(conversationCard.conversationId);
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 11
                    anchors.rightMargin: 8
                    spacing: 9

                    Rectangle {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: 11
                        color: Qt.rgba(navigationRail.accent.r, navigationRail.accent.g, navigationRail.accent.b, 0.13)

                        Text {
                            anchors.centerIn: parent
                            text: conversationCard.provider === "ollama" ? "O" : (conversationCard.provider === "groq" ? "G" : "auto_awesome")
                            font.family: conversationCard.provider === "groq" || conversationCard.provider === "ollama"
                                ? (navigationRail.theme ? navigationRail.theme.fontMain : "Inter")
                                : (navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded")
                            font.pixelSize: conversationCard.provider === "groq" || conversationCard.provider === "ollama" ? 13 : 17
                            font.weight: Font.Bold
                            color: navigationRail.accent
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                Layout.fillWidth: true
                                visible: !conversationCard.renaming
                                text: conversationCard.title
                                elide: Text.ElideRight
                                font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: navigationRail.mainText
                            }

                            TextField {
                                id: renameField
                                Layout.fillWidth: true
                                visible: conversationCard.renaming
                                text: conversationCard.renaming ? navigationRail.renameDraft : ""
                                selectByMouse: true
                                padding: 0
                                background: null
                                color: navigationRail.mainText
                                selectionColor: navigationRail.accent
                                font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                onTextChanged: {
                                    if (conversationCard.renaming)
                                        navigationRail.renameDraft = text;
                                }
                                Keys.onReturnPressed: navigationRail.commitRename()
                                Keys.onEscapePressed: navigationRail.cancelRename()
                            }

                            Text {
                                text: navigationRail.relativeTime(conversationCard.updatedAt)
                                font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                                font.pixelSize: 9
                                color: navigationRail.mutedText
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: conversationCard.confirmingDelete
                                ? "Click delete again to confirm"
                                : (conversationCard.contextOpen ? "Actions available on the right" : conversationCard.preview)
                            elide: Text.ElideRight
                            font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                            font.pixelSize: 10
                            color: conversationCard.confirmingDelete ? "#ff8a8a" : navigationRail.subText
                        }
                    }

                    Row {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 34
                        spacing: 0

                        Item {
                            width: 24
                            height: 34

                            Text {
                                anchors.centerIn: parent
                                text: "edit"
                                font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 16
                                color: navigationRail.mutedText
                                opacity: conversationMouse.containsMouse || conversationCard.contextOpen || conversationCard.renaming ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: !ConversationService.isGenerating
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    navigationRail.beginRename(conversationCard.conversationId, conversationCard.title);
                                    Qt.callLater(function() {
                                        renameField.forceActiveFocus();
                                        renameField.selectAll();
                                    });
                                }
                            }
                        }

                        Item {
                            width: 24
                            height: 34

                            Text {
                                anchors.centerIn: parent
                                text: conversationCard.confirmingDelete ? "delete_forever" : "delete"
                                font.family: navigationRail.theme ? navigationRail.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 17
                                color: conversationCard.confirmingDelete ? "#ff6b6b" : navigationRail.mutedText
                                opacity: conversationMouse.containsMouse || conversationCard.contextOpen || conversationCard.confirmingDelete ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: !ConversationService.isGenerating
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    navigationRail.contextConversationId = "";
                                    if (conversationCard.confirmingDelete) {
                                        ConversationService.deleteConversation(conversationCard.conversationId);
                                        navigationRail.pendingDeleteId = "";
                                    } else {
                                        navigationRail.pendingDeleteId = conversationCard.conversationId;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: conversationList.count === 0
                text: navigationRail.searchText.length > 0 ? "No matching conversations" : "No saved conversations"
                font.family: navigationRail.theme ? navigationRail.theme.fontMain : "Inter"
                font.pixelSize: 11
                color: navigationRail.mutedText
            }
        }

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
                        text: "The active conversation is saved on this device."
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
