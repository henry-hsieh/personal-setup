#!/usr/bin/env node
import * as child_process from "child_process";

const lsp_path = process.argv[2];
if (!lsp_path) {
  process.exit(1);
}

let lspProcess: child_process.ChildProcess;
try {
  lspProcess = child_process.spawn(lsp_path, ["--stdio"]);
} catch (err) {
  console.error("Failed to spawn LSP process: " + err);
  process.exit(1);
}

lspProcess.on("error", (err) => {
  console.error("LSP process error: " + err);
  process.exit(1);
});

let messageId = 1;

function send(method: string, params: unknown): void {
  const message = {
    jsonrpc: "2.0",
    id: messageId++,
    method: method,
    params: params
  };
  const json = JSON.stringify(message);
  const headers = "Content-Length: " + json.length + "\r\n\r\n";
  lspProcess.stdin!.write(headers, "ascii");
  lspProcess.stdin!.write(json, "utf-8");
}

function sendNotification(method: string, params: unknown): void {
  const message = {
    jsonrpc: "2.0",
    method: method,
    params: params
  };
  const json = JSON.stringify(message);
  const headers = "Content-Length: " + json.length + "\r\n\r\n";
  lspProcess.stdin!.write(headers, "ascii");
  lspProcess.stdin!.write(json, "utf-8");
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function waitForInitialize(timeoutMs: number): Promise<void> {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error("Timeout: LSP did not respond to initialize"));
    }, timeoutMs);

    const handler = (data: Buffer): void => {
      const str = data.toString();
      if (str.includes('"result":') || str.includes('"capabilities":')) {
        clearTimeout(timeout);
        lspProcess.stdout!.off("data", handler);
        resolve();
      }
    };

    lspProcess.stdout!.on("data", handler);
  });
}

async function main(): Promise<void> {
  send("initialize", {
    rootPath: process.cwd(),
    processId: process.pid,
    capabilities: {}
  });

  try {
    await waitForInitialize(5000);
  } catch (err) {
    console.error((err as Error).message);
    lspProcess.kill();
    process.exit(1);
  }

  send("shutdown", null);
  await delay(100);

  sendNotification("exit", {});
  await delay(100);

  lspProcess.kill();
  process.exit(0);
}

main();
