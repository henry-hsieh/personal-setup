---
description: automate utility package addition
agent: build
---

<util_name>$1</util_name>
<author_or_organization>$2</author_or_organization>

<instructions>
1. Search GitHub for linux-x86_64 binary releases of `<util_name>`, respecting `<author_or_organization>` if provided.
2. Fall back to official download sites if GitHub search fails.
3. Create `packages/<util_name>/package.yaml` following the specification in `packages/README.md`.
4. Register a new test in `tests/Makefile`.
</instructions>
