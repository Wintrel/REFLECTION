"use strict";

const { requestError } = require("./sse");

async function generate(options) {
    const messages = options.messages.map(message => {
        const msg = {
            role: message.role === "system" ? "system"
                : (message.role === "assistant" ? "assistant" : "user"),
            content: typeof message.text === "string" ? message.text : ""
        };

        if (message.images && message.images.length > 0) {
            msg.images = message.images.map(img => img.data);
        }

        return msg;
    });

    if (typeof options.systemPrompt === "string" && options.systemPrompt.trim().length > 0) {
        messages.unshift({ role: "system", content: options.systemPrompt.trim() });
    }

    let baseUrl = options.url || "http://127.0.0.1:11434";
    if (baseUrl.endsWith("/")) baseUrl = baseUrl.slice(0, -1);
    const url = baseUrl + "/api/chat";

    const payload = { 
        model: options.model || "qwen3.5", 
        messages: messages, 
        stream: true,
        options: {}
    };

    if (typeof options.temperature === "number") payload.options.temperature = options.temperature;
    if (typeof options.numCtx === "number") payload.options.num_ctx = options.numCtx;

    const response = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(payload),
        signal: options.signal
    });

    if (!response.ok)
        await requestError("Ollama", response);

    const decoder = new TextDecoder();
    let pending = "";

    for await (const chunk of response.body) {
        pending += decoder.decode(chunk, { stream: true });
        const lines = pending.split(/\r?\n/);
        pending = lines.pop() || "";
        for (const line of lines) {
            if (!line.trim()) continue;
            try {
                const event = JSON.parse(line);
                if (event.message && typeof event.message.content === "string" && event.message.content.length > 0) {
                    options.onChunk(event.message.content);
                }
            } catch (e) {
                console.error("Ollama JSON parse error:", e);
            }
        }
    }

    if (pending.trim()) {
        try {
            const event = JSON.parse(pending);
            if (event.message && typeof event.message.content === "string" && event.message.content.length > 0) {
                options.onChunk(event.message.content);
            }
        } catch (e) { }
    }
}

module.exports = { generate };
