"use strict";

async function streamSse(response, onEvent) {
    const decoder = new TextDecoder();
    let pending = "";

    function processLine(line) {
        line = line.trim();
        if (!line.startsWith("data:"))
            return;

        const data = line.slice(5).trim();
        if (data.length === 0 || data === "[DONE]")
            return;
        onEvent(JSON.parse(data));
    }

    for await (const chunk of response.body) {
        pending += decoder.decode(chunk, { stream: true });
        const lines = pending.split(/\r?\n/);
        pending = lines.pop() || "";
        for (const line of lines)
            processLine(line);
    }

    pending += decoder.decode();
    if (pending.length > 0)
        processLine(pending);
}

async function requestError(provider, response) {
    let detail = "";
    try {
        const body = await response.text();
        detail = body.length > 2000 ? body.slice(0, 2000) + "…" : body;
    } catch (_) {
        detail = "The server did not return an error body.";
    }
    throw new Error(provider + " request failed (HTTP " + response.status + "): " + detail);
}

module.exports = { streamSse, requestError };
