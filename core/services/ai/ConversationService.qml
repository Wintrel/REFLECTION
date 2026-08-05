pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/quickshell/reflection/.ai_settings.json"
    readonly property string legacyHistoryPath: Quickshell.env("HOME") + "/.config/quickshell/reflection/.ai_history.json"
    readonly property string storageDirectory: Quickshell.dataPath("assistant")
    readonly property string conversationsDirectory: storageDirectory + "/conversations"
    readonly property string indexPath: storageDirectory + "/index.json"
    readonly property string storageHelperPath: Qt.resolvedUrl("conversation_store.py").toString().replace(/^file:\/\//, "")

    property alias messages: messageModel
    property alias conversations: conversationModel
    readonly property bool hasMessages: messageModel.count > 0
    readonly property bool hasActiveConversation: activeConversationId.length > 0
    property string activeConversationId: ""
    property string activeConversationTitle: "New conversation"
    property string lastUserMessage: ""
    property string contextSummary: ""
    property bool isCompacting: false
    property string compactionBuffer: ""
    property string pendingContext: ""
    readonly property int contextCharacterBudget: 24000
    readonly property int recentContextCharacterBudget: 12000
    readonly property int contextCharacterCount: revision >= 0
        ? messageCharacterCount(providerMessages()) : 0
    readonly property bool contextNearLimit: contextCharacterCount >= contextCharacterBudget
    readonly property bool hasContextSummary: contextSummary.length > 0

    property string providerId: "gemini"
    readonly property bool isGenerating: AiDaemonService.isGenerating
    readonly property bool providerConfigured: AiDaemonService.configuredFor(providerId)
    readonly property string providerName: providerId === "groq" ? "Groq" : "Gemini"
    readonly property string providerModel: AiDaemonService.modelFor(providerId)
    readonly property bool groqConfigured: AiDaemonService.groqConfigured
    readonly property bool geminiConfigured: AiDaemonService.geminiConfigured
    readonly property string groqModel: AiDaemonService.groqModel
    readonly property string geminiModel: AiDaemonService.geminiModel
    readonly property bool daemonHealthy: AiDaemonService.healthy
    readonly property string daemonStatus: AiDaemonService.daemonStatus
    readonly property string daemonError: AiDaemonService.lastError
    property string settingsError: ""

    property int activeResponseIndex: -1
    property int revision: 0
    property int conversationsRevision: 0
    property bool loaded: false
    property bool storageReady: false

    function loadProviderSettings() {
        try {
            var cfg = JSON.parse(settingsFile.text() || "{}");
            if (cfg.aiProvider === "groq" || cfg.aiProvider === "gemini") {
                root.providerId = cfg.aiProvider;
            } else {
                root.providerId = typeof cfg.groqApiKey === "string" && cfg.groqApiKey.trim().length > 0
                    ? "groq"
                    : "gemini";
            }
        } catch (error) {
            root.providerId = "gemini";
            console.warn("ConversationService: could not load provider settings: " + error);
        }
    }

    function setProvider(nextProviderId) {
        if ((nextProviderId !== "groq" && nextProviderId !== "gemini") || root.isGenerating)
            return false;

        try {
            var cfg = JSON.parse(settingsFile.text() || "{}");
            cfg.aiProvider = nextProviderId;
            root.providerId = nextProviderId;
            settingsFile.setText(JSON.stringify(cfg, null, 2));
            return true;
        } catch (error) {
            console.warn("ConversationService: could not save provider selection: " + error);
            return false;
        }
    }

    function saveProviderSettings(provider, nextModel, replacementKey) {
        if ((provider !== "groq" && provider !== "gemini") || root.isGenerating)
            return false;

        var model = String(nextModel).trim();
        if (model.length === 0) {
            root.settingsError = "The model name cannot be empty.";
            return false;
        }

        try {
            var cfg = JSON.parse(settingsFile.text() || "{}");
            var modelProperty = provider === "groq" ? "groqModel" : "geminiModel";
            var keyProperty = provider === "groq" ? "groqApiKey" : "geminiApiKey";
            cfg[modelProperty] = model;
            if (typeof replacementKey === "string" && replacementKey.trim().length > 0)
                cfg[keyProperty] = replacementKey.trim();
            settingsFile.setText(JSON.stringify(cfg, null, 2));
            root.settingsError = "";
            return true;
        } catch (error) {
            root.settingsError = "Could not save AI settings: " + error;
            console.warn("ConversationService: " + root.settingsError);
            return false;
        }
    }

    function removeProviderKey(provider) {
        if ((provider !== "groq" && provider !== "gemini") || root.isGenerating)
            return false;

        try {
            var cfg = JSON.parse(settingsFile.text() || "{}");
            cfg[provider === "groq" ? "groqApiKey" : "geminiApiKey"] = "";
            settingsFile.setText(JSON.stringify(cfg, null, 2));
            root.settingsError = "";
            return true;
        } catch (error) {
            root.settingsError = "Could not remove the API key: " + error;
            console.warn("ConversationService: " + root.settingsError);
            return false;
        }
    }

    function restartDaemon() {
        if (root.isGenerating)
            return false;
        AiDaemonService.restartDaemon();
        return true;
    }

    function newConversationId() {
        return Date.now().toString(36) + "-" + Math.random().toString(36).substring(2, 8);
    }

    function conversationPath(conversationId) {
        return root.conversationsDirectory + "/" + conversationId + ".json";
    }

    function titleFromPrompt(prompt) {
        var title = prompt.replace(/\s+/g, " ").trim();
        if (title.length > 52)
            title = title.substring(0, 51).trim() + "…";
        return title || "New conversation";
    }

    function conversationIndex(conversationId) {
        for (var i = 0; i < conversationModel.count; i++) {
            if (conversationModel.get(i).conversationId === conversationId)
                return i;
        }
        return -1;
    }

    function appendStoredMessages(entries, summary) {
        messageModel.clear();
        root.lastUserMessage = "";
        root.activeResponseIndex = -1;
        root.contextSummary = typeof summary === "string" ? summary : "";
        root.isCompacting = false;
        root.compactionBuffer = "";

        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (!entry || (entry.role !== "user" && entry.role !== "assistant")
                    || typeof entry.text !== "string")
                continue;

            var status = entry.status === "error" || entry.status === "stopped"
                ? entry.status : "complete";
            if (entry.status === "streaming") {
                status = "error";
                if (entry.role === "assistant" && entry.text.length === 0)
                    entry.text = "Response interrupted before completion.";
            }

            messageModel.append({ role: entry.role, text: entry.text, status: status, contextSources: entry.contextSources || "", imagePaths: JSON.stringify(entry.imagePaths || []) });
            if (entry.role === "user")
                root.lastUserMessage = entry.text;
        }
    }

    function loadStorage() {
        conversationModel.clear();
        var stored = {};
        try {
            stored = JSON.parse(indexFile.text() || "{}");
        } catch (error) {
            console.warn("ConversationService: could not load conversation index: " + error);
        }

        var entries = Array.isArray(stored.conversations) ? stored.conversations : [];
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (!entry || typeof entry.id !== "string" || !/^[A-Za-z0-9_-]+$/.test(entry.id))
                continue;
            conversationModel.append({
                conversationId: entry.id,
                title: typeof entry.title === "string" ? entry.title : "Conversation",
                preview: typeof entry.preview === "string" ? entry.preview : "",
                createdAt: typeof entry.createdAt === "string" ? entry.createdAt : "",
                updatedAt: typeof entry.updatedAt === "string" ? entry.updatedAt : "",
                provider: entry.provider === "gemini" ? "gemini" : "groq"
            });
        }

        if (conversationModel.count === 0 && migrateLegacyHistory()) {
            root.loaded = true;
            return;
        }

        var requestedId = typeof stored.activeConversationId === "string"
            ? stored.activeConversationId
            : "";
        if (root.conversationIndex(requestedId) < 0 && conversationModel.count > 0)
            requestedId = conversationModel.get(0).conversationId;

        root.loaded = true;
        root.conversationsRevision++;
        if (requestedId.length > 0)
            selectConversation(requestedId, false);
        else
            clearActiveConversation();
    }

    function migrateLegacyHistory() {
        try {
            var legacy = JSON.parse(legacyHistoryFile.text() || "{}");
            var entries = Array.isArray(legacy.messages) ? legacy.messages : [];
            if (entries.length === 0)
                return false;

            var firstPrompt = "Imported conversation";
            for (var i = 0; i < entries.length; i++) {
                if (entries[i].role === "user" && typeof entries[i].text === "string") {
                    firstPrompt = entries[i].text;
                    break;
                }
            }

            var conversationId = newConversationId();
            var now = new Date().toISOString();
            root.activeConversationId = conversationId;
            root.activeConversationTitle = titleFromPrompt(firstPrompt);
            activeConversationFile.path = conversationPath(conversationId);
            appendStoredMessages(entries, "");
            conversationModel.append({
                conversationId: conversationId,
                title: root.activeConversationTitle,
                preview: root.lastUserMessage,
                createdAt: now,
                updatedAt: now,
                provider: root.providerId
            });
            persistActiveConversation();
            persistIndex();
            root.revision++;
            root.conversationsRevision++;
            return true;
        } catch (error) {
            console.warn("ConversationService: could not migrate legacy history: " + error);
            return false;
        }
    }

    function clearActiveConversation() {
        root.activeConversationId = "";
        root.activeConversationTitle = "New conversation";
        root.lastUserMessage = "";
        root.contextSummary = "";
        root.isCompacting = false;
        root.compactionBuffer = "";
        root.activeResponseIndex = -1;
        activeConversationFile.path = "";
        messageModel.clear();
        root.revision++;
    }

    function newConversation() {
        if (root.isGenerating || !root.storageReady)
            return false;

        var conversationId = newConversationId();
        var now = new Date().toISOString();
        conversationModel.insert(0, {
            conversationId: conversationId,
            title: "New conversation",
            preview: "No messages yet",
            createdAt: now,
            updatedAt: now,
            provider: root.providerId
        });
        root.activeConversationId = conversationId;
        root.activeConversationTitle = "New conversation";
        root.lastUserMessage = "";
        root.contextSummary = "";
        root.isCompacting = false;
        root.compactionBuffer = "";
        root.activeResponseIndex = -1;
        activeConversationFile.path = conversationPath(conversationId);
        messageModel.clear();
        persistActiveConversation();
        persistIndex();
        root.revision++;
        root.conversationsRevision++;
        return true;
    }

    function selectConversation(conversationId, saveSelection) {
        if (root.isGenerating)
            return false;
        var index = conversationIndex(conversationId);
        if (index < 0)
            return false;

        root.activeConversationId = conversationId;
        root.activeConversationTitle = conversationModel.get(index).title;
        activeConversationFile.path = conversationPath(conversationId);

        try {
            var stored = JSON.parse(activeConversationFile.text() || "{}");
            appendStoredMessages(Array.isArray(stored.messages) ? stored.messages : [], stored.contextSummary);
        } catch (error) {
            appendStoredMessages([], "");
            console.warn("ConversationService: could not load conversation " + conversationId + ": " + error);
        }

        if (saveSelection === undefined || saveSelection)
            persistIndex();
        root.revision++;
        return true;
    }

    function deleteConversation(conversationId) {
        if (root.isGenerating)
            return false;
        var index = conversationIndex(conversationId);
        if (index < 0)
            return false;

        storageProcess.write(JSON.stringify({
            operation: "delete-conversation",
            path: conversationPath(conversationId)
        }) + "\n");
        var deletingActive = conversationId === root.activeConversationId;
        conversationModel.remove(index);

        if (deletingActive) {
            if (conversationModel.count > 0)
                selectConversation(conversationModel.get(Math.min(index, conversationModel.count - 1)).conversationId, false);
            else
                clearActiveConversation();
        }
        persistIndex();
        root.conversationsRevision++;
        return true;
    }

    function renameConversation(conversationId, nextTitle) {
        if (root.isGenerating)
            return false;
        var index = conversationIndex(conversationId);
        var title = String(nextTitle).replace(/\s+/g, " ").trim();
        if (index < 0 || title.length === 0)
            return false;
        if (title.length > 80)
            title = title.substring(0, 80).trim();

        conversationModel.setProperty(index, "title", title);
        conversationModel.setProperty(index, "updatedAt", new Date().toISOString());
        if (conversationId === root.activeConversationId)
            root.activeConversationTitle = title;

        storageProcess.write(JSON.stringify({
            operation: "rename-conversation",
            path: conversationPath(conversationId),
            title: title
        }) + "\n");
        persistIndex();
        root.conversationsRevision++;
        return true;
    }

    function startTurn(prompt, contextSources, imagePaths) {
        prompt = prompt.trim();
        if (prompt.length === 0 || root.activeResponseIndex !== -1)
            return false;
        if (!root.hasActiveConversation && !newConversation())
            return false;

        messageModel.append({ role: "user", text: prompt, status: "complete", contextSources: contextSources || "", imagePaths: JSON.stringify(imagePaths || []) });
        messageModel.append({ role: "assistant", text: "", status: "streaming", contextSources: "", imagePaths: "[]" });
        root.activeResponseIndex = messageModel.count - 1;
        root.lastUserMessage = prompt;

        var index = conversationIndex(root.activeConversationId);
        if (index >= 0) {
            if (conversationModel.get(index).title === "New conversation") {
                root.activeConversationTitle = root.titleFromPrompt(prompt);
                conversationModel.setProperty(index, "title", root.activeConversationTitle);
            }
            conversationModel.setProperty(index, "preview", prompt);
            conversationModel.setProperty(index, "updatedAt", new Date().toISOString());
            conversationModel.setProperty(index, "provider", root.providerId);
        }
        persistActiveConversation();
        persistIndex();
        root.revision++;
        root.conversationsRevision++;
        return true;
    }

    function sendMessage(prompt, contextPayload, contextSources, imagePaths) {
        if (root.isGenerating || !startTurn(prompt, contextSources, imagePaths))
            return false;
        root.pendingContext = typeof contextPayload === "string" ? contextPayload : "";
        return startResponseGeneration();
    }

    function stopGeneration() {
        return AiDaemonService.stopGeneration();
    }

    function canRegenerateResponse(messageIndex) {
        if (root.isGenerating || messageIndex !== messageModel.count - 1 || messageIndex < 1)
            return false;
        var response = messageModel.get(messageIndex);
        var prompt = messageModel.get(messageIndex - 1);
        return response.role === "assistant" && response.status !== "streaming"
            && prompt.role === "user" && prompt.text.length > 0;
    }

    function regenerateResponse(messageIndex) {
        if (!canRegenerateResponse(messageIndex))
            return false;

        messageModel.remove(messageIndex);
        messageModel.append({ role: "assistant", text: "", status: "streaming", contextSources: "", imagePaths: "[]" });
        root.activeResponseIndex = messageModel.count - 1;

        var conversation = conversationIndex(root.activeConversationId);
        if (conversation >= 0) {
            conversationModel.setProperty(conversation, "updatedAt", new Date().toISOString());
            conversationModel.setProperty(conversation, "provider", root.providerId);
        }
        persistActiveConversation();
        persistIndex();
        root.revision++;
        root.conversationsRevision++;

        return startResponseGeneration();
    }

    function copyMessage(messageIndex) {
        if (messageIndex < 0 || messageIndex >= messageModel.count)
            return false;
        var text = messageModel.get(messageIndex).text;
        if (typeof text !== "string" || text.length === 0)
            return false;

        var process = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        process.command = ["wl-copy"];
        process.stdinEnabled = true;
        process.exited.connect(function() { process.destroy(); });
        process.running = true;
        process.write(text);
        process.stdinEnabled = false;
        return true;
    }

    function appendAssistantChunk(text) {
        if (root.isCompacting) {
            root.compactionBuffer += text;
            return;
        }
        if (root.activeResponseIndex < 0 || typeof text !== "string")
            return;
        var current = messageModel.get(root.activeResponseIndex).text;
        messageModel.setProperty(root.activeResponseIndex, "text", current + text);
        root.revision++;
    }

    function finishTurn() {
        if (root.activeResponseIndex < 0)
            return;
        messageModel.setProperty(root.activeResponseIndex, "status", "complete");
        root.activeResponseIndex = -1;
        root.pendingContext = "";

        updateActiveMetadata();
        persistActiveConversation();
        persistIndex();
        root.revision++;
    }

    function failTurn(errorMessage) {
        if (root.activeResponseIndex < 0)
            return;
        messageModel.setProperty(root.activeResponseIndex, "text", "Error: " + errorMessage);
        messageModel.setProperty(root.activeResponseIndex, "status", "error");
        root.activeResponseIndex = -1;
        root.pendingContext = "";
        updateActiveMetadata();
        persistActiveConversation();
        persistIndex();
        root.revision++;
    }

    function stopTurn() {
        if (root.activeResponseIndex < 0)
            return;
        if (messageModel.get(root.activeResponseIndex).text.length === 0)
            messageModel.setProperty(root.activeResponseIndex, "text", "Response stopped.");
        messageModel.setProperty(root.activeResponseIndex, "status", "stopped");
        root.activeResponseIndex = -1;
        root.pendingContext = "";
        updateActiveMetadata();
        persistActiveConversation();
        persistIndex();
        root.revision++;
    }

    function updateActiveMetadata() {
        var index = conversationIndex(root.activeConversationId);
        if (index < 0)
            return;
        conversationModel.setProperty(index, "preview", root.lastUserMessage || "No messages yet");
        conversationModel.setProperty(index, "updatedAt", new Date().toISOString());
        conversationModel.setProperty(index, "provider", root.providerId);
        root.conversationsRevision++;
    }

    function usableMessages() {
        var entries = [];
        for (var i = 0; i < messageModel.count; i++) {
            var message = messageModel.get(i);
            if (message.status === "streaming" || message.status === "error"
                    || message.status === "stopped" || message.text.length === 0)
                continue;
            entries.push({ role: message.role, text: message.text, contextSources: message.contextSources || "", imagePaths: JSON.parse(message.imagePaths || "[]") });
        }
        return entries;
    }

    function messageCharacterCount(entries) {
        var total = 0;
        for (var i = 0; i < entries.length; i++)
            total += entries[i].text.length;
        return total;
    }

    function recentMessages(entries) {
        var kept = [];
        var characters = 0;
        for (var i = entries.length - 1; i >= 0; i--) {
            var message = entries[i];
            if (kept.length > 0 && characters + message.text.length > root.recentContextCharacterBudget)
                break;
            kept.unshift(message);
            characters += message.text.length;
        }
        var firstKeptIndex = entries.length - kept.length;
        if (kept.length > 0 && kept[0].role === "assistant" && firstKeptIndex > 0)
            kept.unshift(entries[firstKeptIndex - 1]);
        return kept;
    }

    function clearContextSummary() {
        if (root.isGenerating || root.contextSummary.length === 0)
            return false;
        root.contextSummary = "";
        persistActiveConversation();
        root.revision++;
        return true;
    }

    function compactionTranscript() {
        var entries = usableMessages();
        if (messageCharacterCount(entries) + root.contextSummary.length <= root.contextCharacterBudget)
            return "";
        var recent = recentMessages(entries);
        var olderCount = entries.length - recent.length;
        if (olderCount <= 0)
            return "";
        var transcript = "";
        if (root.contextSummary.length > 0)
            transcript += "Existing summary:\n" + root.contextSummary + "\n\n";
        for (var i = 0; i < olderCount; i++)
            transcript += entries[i].role.toUpperCase() + ": " + entries[i].text + "\n\n";
        return transcript;
    }

    function providerMessages() {
        var entries = usableMessages();
        if (root.contextSummary.length > 0 || messageCharacterCount(entries) > root.contextCharacterBudget)
            entries = recentMessages(entries);
        if (root.contextSummary.length > 0)
            entries.unshift({ role: "system", text: "Earlier conversation summary. Use it as context, but prioritize the newest messages:\n" + root.contextSummary });

        if (root.pendingContext.length > 0) {
            for (var i = entries.length - 1; i >= 0; i--) {
                if (entries[i].role === "user") {
                    entries[i] = {
                        role: "user",
                        text: "Please use the following context to answer my prompt if relevant:\n\n" + root.pendingContext + entries[i].text,
                        contextSources: entries[i].contextSources || "",
                        imagePaths: entries[i].imagePaths || []
                    };
                    break;
                }
            }
        }

        return entries;
    }

    function startResponseGeneration() {
        var transcript = compactionTranscript();
        if (transcript.length === 0)
            return AiDaemonService.generate(root.providerId, root.providerModel, providerMessages()).length > 0;

        root.isCompacting = true;
        root.compactionBuffer = "";
        if (root.activeResponseIndex >= 0)
            messageModel.setProperty(root.activeResponseIndex, "text", "Preparing earlier context…");
        root.revision++;
        var prompt = "Summarize the earlier portion of this conversation for a future assistant response. Preserve user goals, decisions, constraints, names, and unresolved questions. Be concise and factual. Do not answer the conversation or mention this instruction.\n\n" + transcript;
        return AiDaemonService.generate(root.providerId, root.providerModel,
            [{ role: "user", text: prompt }]).length > 0;
    }

    function finishCompaction() {
        var summary = root.compactionBuffer.trim();
        root.isCompacting = false;
        root.compactionBuffer = "";
        if (summary.length === 0) {
            failTurn("Context preparation returned no summary.");
            return;
        }
        root.contextSummary = summary.length > 7000 ? summary.substring(0, 7000) : summary;
        if (root.activeResponseIndex >= 0)
            messageModel.setProperty(root.activeResponseIndex, "text", "");
        persistActiveConversation();
        root.revision++;
        if (AiDaemonService.generate(root.providerId, root.providerModel, providerMessages()).length === 0)
            failTurn(AiDaemonService.lastError || "Could not continue after context preparation.");
    }

    function serializedMessages() {
        var entries = [];
        for (var i = 0; i < messageModel.count; i++) {
            var message = messageModel.get(i);
            var entry = { role: message.role, text: message.text, status: message.status, contextSources: message.contextSources || "", imagePaths: JSON.parse(message.imagePaths || "[]") };
            if (message.contextSources && message.contextSources.length > 0)
                entry.contextSources = message.contextSources;
            entries.push(entry);
        }
        return entries;
    }

    function persistActiveConversation() {
        if (!root.storageReady || !root.hasActiveConversation)
            return;
        var index = conversationIndex(root.activeConversationId);
        var metadata = index >= 0 ? conversationModel.get(index) : {};
        storageProcess.write(JSON.stringify({
            operation: "write-conversation",
            path: conversationPath(root.activeConversationId),
            contents: JSON.stringify({
                version: 1,
                id: root.activeConversationId,
                title: root.activeConversationTitle,
                createdAt: metadata.createdAt || new Date().toISOString(),
                updatedAt: metadata.updatedAt || new Date().toISOString(),
                provider: metadata.provider || root.providerId,
                contextSummary: root.contextSummary,
                messages: serializedMessages()
            }, null, 2)
        }) + "\n");
    }

    function persistIndex() {
        if (!root.storageReady)
            return;
        var entries = [];
        for (var i = 0; i < conversationModel.count; i++) {
            var conversation = conversationModel.get(i);
            entries.push({
                id: conversation.conversationId,
                title: conversation.title,
                preview: conversation.preview,
                createdAt: conversation.createdAt,
                updatedAt: conversation.updatedAt,
                provider: conversation.provider
            });
        }
        storageProcess.write(JSON.stringify({
            operation: "write-index",
            path: root.indexPath,
            contents: JSON.stringify({
                version: 1,
                activeConversationId: root.activeConversationId,
                conversations: entries
            }, null, 2)
        }) + "\n");
    }

    ListModel { id: messageModel }
    ListModel { id: conversationModel }

    FileView {
        id: settingsFile
        path: root.settingsPath
        preload: true
        blockLoading: true
        watchChanges: true
        printErrors: false
        onLoaded: root.loadProviderSettings()
        onFileChanged: reload()
        onSaved: settingsPermissions.running = true
    }

    FileView {
        id: legacyHistoryFile
        path: root.legacyHistoryPath
        preload: true
        blockLoading: true
        printErrors: false
    }

    FileView {
        id: indexFile
        path: root.storageReady ? root.indexPath : ""
        preload: true
        blockAllReads: true
        printErrors: false
    }

    FileView {
        id: activeConversationFile
        preload: true
        blockAllReads: true
        printErrors: false
    }

    Process {
        id: settingsPermissions
        command: ["chmod", "600", root.settingsPath]
    }

    Process {
        id: storageProcess
        command: ["python3", root.storageHelperPath, root.storageDirectory]
        stdinEnabled: true
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    var event = JSON.parse(data);
                    if (event.type === "ready") {
                        root.storageReady = true;
                        Qt.callLater(root.loadStorage);
                    } else if (event.type === "error") {
                        console.warn("ConversationService storage: " + event.message);
                    }
                } catch (error) {
                    console.warn("ConversationService: invalid storage response: " + error);
                }
            }
        }
    }

    Connections {
        target: AiDaemonService
        function onChunkReceived(requestId, text) { root.appendAssistantChunk(text); }
        function onGenerationFinished(requestId) {
            if (root.isCompacting)
                root.finishCompaction();
            else
                root.finishTurn();
        }
        function onGenerationError(requestId, errorMsg) {
            root.isCompacting = false;
            root.compactionBuffer = "";
            root.failTurn(errorMsg);
        }
        function onGenerationStopped(requestId) {
            root.isCompacting = false;
            root.compactionBuffer = "";
            root.stopTurn();
        }
    }

    Component.onCompleted: loadProviderSettings()
}
