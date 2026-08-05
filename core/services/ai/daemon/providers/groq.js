"use strict";

const { streamSse, requestError } = require("./sse");

async function generate(options) {
    const messages = options.messages
        .filter(message => typeof message.text === "string")
        .map(message => ({
            role: message.role === "assistant" ? "assistant" : "user",
            content: message.text
        }));

    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + options.apiKey
        },
        body: JSON.stringify({ model: options.model, messages, stream: true }),
        signal: options.signal
    });

    if (!response.ok)
        await requestError("Groq", response);

    await streamSse(response, event => {
        const text = event?.choices?.[0]?.delta?.content;
        if (typeof text === "string" && text.length > 0)
            options.onChunk(text);
    });
}

module.exports = { generate };
