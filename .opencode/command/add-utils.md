---
description: Automates the addition of a new utility package
agent: build
---
Search GitHub for a prebuilt binary release of '$1' for the linux-x86_64 architecture. If a suitable binary is not found on GitHub, search the web for the official download site.
Create a new file `packages/$1/package.yaml`. Following the package specification in `packages/README.md`:
Add a test to `tests/Makefile`.

