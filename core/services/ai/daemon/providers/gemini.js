"use strict";

const { streamSse, requestError } = require("./sse");

async function generate(options) {
    const systemParts = options.messages
        .filter(message => message.role === "system" && typeof message.text === "string")
        .map(message => ({ text: message.text }));
    const contents = options.messages
        .filter(message => message.role !== "system" && typeof message.text === "string")
        .map(message => ({
            role: message.role === "assistant" ? "model" : "user",
            parts: [{ text: message.text }]
        }));
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
