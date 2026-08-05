#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const readline = require("node:readline");
const gemini = require("./providers/gemini");
const groq = require("./providers/groq");

const settingsPath = process.argv[2];
const activeRequests = new Map();

function emit(event) {
    process.stdout.write(JSON.stringify(event) + "\n");
}

function errorMessage(error) {
    return error instanceof Error ? error.message : String(error);
}

function loadSettings() {
    if (!settingsPath)
        throw new Error("The daemon was started without a settings path.");
    return JSON.parse(fs.readFileSync(settingsPath, "utf8"));
}

function providerOptions(provider, settings) {
    if (provider === "groq") {
        return {
            adapter: groq,
            apiKey: typeof settings.groqApiKey === "string" ? settings.groqApiKey.trim() : "",
            model: typeof settings.groqModel === "string" && settings.groqModel.trim()
                ? settings.groqModel.trim() : "llama-3.1-8b-instant"
        };
    }
    if (provider === "gemini") {
        return {
            adapter: gemini,
            apiKey: typeof settings.geminiApiKey === "string" ? settings.geminiApiKey.trim() : "",
            model: typeof settings.geminiModel === "string" && settings.geminiModel.trim()
                ? settings.geminiModel.trim() : "gemini-3.6-flash"
        };
    }
    throw new Error("Unsupported AI provider: " + provider);
}

async function generate(command) {
    const requestId = typeof command.requestId === "string" ? command.requestId : "";
    if (!requestId)
        throw new Error("A generation request needs a requestId.");
    if (activeRequests.has(requestId))
        throw new Error("Request " + requestId + " is already active.");
    if (!Array.isArray(command.messages) || command.messages.length === 0)
        throw new Error("There are no conversation messages to send.");

    const settings = loadSettings();
    const options = providerOptions(command.provider, settings);
    if (!options.apiKey)
        throw new Error((command.provider === "groq" ? "Groq" : "Gemini") + " API key is not set.");

    for (const msg of command.messages) {
        if (msg.imagePaths && msg.imagePaths.length > 0) {
            msg.images = [];
            for (const path of msg.imagePaths) {
                try {
                    const data = fs.readFileSync(path);
                    const lowerPath = path.toLowerCase();
                    let mime = "image/png";
                    if (lowerPath.endsWith(".jpg") || lowerPath.endsWith(".jpeg")) mime = "image/jpeg";
                    else if (lowerPath.endsWith(".webp")) mime = "image/webp";
                    
                    msg.images.push({
                        data: data.toString("base64"),
                        mimeType: mime
                    });
                } catch (err) {
                    // Ignore missing image files silently
                }
            }
        }
    }

    const controller = new AbortController();
    activeRequests.set(requestId, controller);
    emit({ type: "started", requestId });

    try {
        await options.adapter.generate({
            apiKey: options.apiKey,
            model: typeof command.model === "string" && command.model.trim()
                ? command.model.trim() : options.model,
            messages: command.messages,
            signal: controller.signal,
            onChunk: text => emit({ type: "chunk", requestId, text })
        });
        emit({ type: "finished", requestId });
    } catch (error) {
        if (controller.signal.aborted)
            emit({ type: "stopped", requestId });
        else
            emit({ type: "error", requestId, message: errorMessage(error) });
    } finally {
        activeRequests.delete(requestId);
    }
}

function cancel(requestId) {
    const controller = activeRequests.get(requestId);
    if (controller)
        controller.abort();
}

const input = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });
input.on("line", line => {
    let command;
    try {
        command = JSON.parse(line);
        if (command.action === "generate") {
            generate(command).catch(error => emit({
                type: "error",
                requestId: command.requestId || "",
                message: errorMessage(error)
            }));
        } else if (command.action === "cancel") {
            cancel(command.requestId);
        } else if (command.action === "ping") {
            emit({ type: "pong" });
        } else {
            throw new Error("Unknown daemon action.");
        }
    } catch (error) {
        emit({ type: "error", requestId: command?.requestId || "", message: errorMessage(error) });
    }
});

function shutdown() {
    for (const controller of activeRequests.values())
        controller.abort();
    input.close();
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
emit({ type: "ready" });
