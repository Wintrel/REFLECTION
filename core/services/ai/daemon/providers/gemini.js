"use strict";

const { streamSse, requestError } = require("./sse");

async function generate(options) {
    const systemParts = options.messages
        .filter(message => message.role === "system" && typeof message.text === "string")
        .map(message => ({ text: message.text }));
    const contents = options.messages
        .filter(message => message.role !== "system")
        .map(message => {
            const parts = [];
            if (message.images && message.images.length > 0) {
                for (const img of message.images) {
                    parts.push({
                        inlineData: {
                            mimeType: img.mimeType || "image/png",
                            data: img.data
                        }
                    });
                }
            }
            if (typeof message.text === "string" && message.text.length > 0) {
                parts.push({ text: message.text });
            }
            return {
                role: message.role === "assistant" ? "model" : "user",
                parts: parts
            };
        });
    const url = "https://generativelanguage.googleapis.com/v1beta/models/"
        + encodeURIComponent(options.model) + ":streamGenerateContent?alt=sse";

    const response = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": options.apiKey
        },
        body: JSON.stringify(systemParts.length > 0
            ? { systemInstruction: { parts: systemParts }, contents }
            : { contents }),
        signal: options.signal
    });

    if (!response.ok)
        await requestError("Gemini", response);

    await streamSse(response, event => {
        const parts = event?.candidates?.[0]?.content?.parts;
        if (!Array.isArray(parts))
            return;
        for (const part of parts) {
            if (typeof part.text === "string" && part.text.length > 0)
                options.onChunk(part.text);
        }
    });
}

module.exports = { generate };
