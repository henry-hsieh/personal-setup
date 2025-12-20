---
description: add utility to the package
agent: build
---
Search prebuilt linux-x86 version release of `$1` in GitHub. If the prebuilt binary is not available at GitHub, search web to find host site.
Create a new file `packages/$1/package.yaml`. Following the package specification in `packages/README.md`:
Add a test to `tests/Makefile`.

