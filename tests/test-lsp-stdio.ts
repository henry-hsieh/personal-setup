#!/usr/bin/env node
import * as child_process from "child_process";

const lsp_path = process.argv[2]
console.log("Test LSP: " + lsp_path);
let lspProcess = child_process.spawn(lsp_path, ["--stdio" ]);
let messageId = 1;

function send(method: string, params: object) {
    let message = {
        jsonrpc: "2.0",
        id: messageId++,
        method: method,
        params: params
    };
    let json = JSON.stringify(message);
    let headers = "Content-Length: " + json.length + "\r\n\r\n";
    lspProcess.stdin.write(headers, "ASCII");
    lspProcess.stdin.write(json, "UTF-8");
    console.log(headers + json);
}

function initialize() {
    send("initialize", {
        rootPath: process.cwd(),
        processId: process.pid,
        capabilities: {
            /* ... */
        }
    });
}

function shutdown() {
    send("shutdown", null);
}

function exit() {
    let message = {
        jsonrpc: "2.0",
        method: "exit",
        params: {}
    };
    let json = JSON.stringify(message);
    let headers = "Content-Length: " + json.length + "\r\n\r\n";
    lspProcess.stdin.write(headers, "ASCII");
    lspProcess.stdin.write(json, "UTF-8");
}

lspProcess.stdout.on("data", (message) => {
    // "Content-Length: ...\r\n\r\n\" will be included here
    console.log(message.toString() + "\r\n");
});

initialize();
shutdown();
exit();
