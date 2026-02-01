---
description: commit current changes following guidelines
agent: build
---

<input_type>$1</input_type>
<category>$2</category>
<summary>$3</summary>

<arguments>

All arguments are optional:

| Argument | Description |
|----------|-------------|
| **type** | Conventional commit type: feat, fix, refactor, build, ci, test, docs, style, chore |
| **category** | Package or module name (e.g., nvim, tmux). MAY be empty. |
| **summary** | Custom commit summary.|

</arguments>

<instructions>
The agent MUST commit current changes following the Git and Pull Request Guidelines defined in AGENTS.md.
</instructions>

<workflow>

<step name="determine-type">

## 1. Determine Commit Type

Resolution order:
1. If `<input_type>` argument is provided, MUST use it.
2. If `<input_type>` is end with `!`, the commit is a BREAKING-CHANGE commit. Otherwise, the commit is a normal commit.
3. The `<type>` is `<input_type>` stripping `!`.
4. If current branch matches `<type>-*` pattern (e.g., `feat-nvim-foo`), SHOULD extract type from branch name.
5. Otherwise, MUST use the `question` tool to ask user to select:
   - `feat`: New feature
   - `fix`: Bug fix
   - `refactor`: Code refactoring
   - `build`: Build system changes
   - `ci`: CI/CD changes
   - `test`: Test changes
   - `docs`: Documentation
   - `style`: Code style
   - `chore`: Other changes

</step>

<step name="determine-category">

## 2. Determine Category

Resolution order:
1. If `<category>` argument is provided, MUST use it (empty string, `-`, or `N/A` means no category).
2. If current branch matches `<type>-<category>-*` pattern, SHOULD extract category from branch name.
3. Otherwise, SHOULD infer from changed files:
   - Files in `packages/<name>/` → category is `<name>`
   - Files in `src/settings/<name>/` → category is `<name>`
   - Mixed or root-level changes → no category

</step>

<step name="determine-summary">

## 3. Determine Summary

- If `<summary>` argument is provided:
  - MUST fix typos only; preserve user's wording.
- If `<summary>` is not provided:
  - MUST generate a concise summary based on staged changes.
  - SHOULD keep it under 50 characters.

</step>

<step name="branch-management">

## 4. Branch Management

If current branch is `main`, MUST create a new branch.

<rules>
- Format: `<type>-<category>-<short_summary>` or `<type>-<short_summary>` if no category
- `<short_summary>` MUST be dash-separated and MUST NOT exceed 3 words
</rules>

<examples>
- `feat-nvim-add-plugin`
- `fix-tmux-keybinding`
- `chore-update-deps`
</examples>

</step>

<step name="commit-message">

## 5. Commit Message Format

<rules>
- Normal change with category: `<type>(<category>): <summary>`
- Normal change without category: `<type>: <summary>`
- BREAKING-CHANGE with category: `<type>(<category>)!: <summary>`
- BREAKING-CHANGE without category: `<type>!: <summary>`
</rules>

</step>

<step name="commit-strategy">

## 6. Commit Strategy

- If an unmerged commit exists on current branch, SHOULD squash to the unmerged commit and SHOULD reword the message.
- If no unmerged commit exists, MUST create a new commit.

</step>

<step name="pr-init">

## 7. Pull Request Initialization

MUST push changes to upstream. If no PR exists, MUST create a draft PR.

</step>

<step name="pr-content">

## 8. PR Content

MUST use this template for the PR body:

<format name="pr-body">
# OpenCode AI Summary

**Purpose:** {purpose_of_pr}

**Summary:** {summary_of_all_changes_against_main_branch}

---
*This summary was generated automatically by OpenCode.*
</format>

</step>

<step name="pr-updates">

## 9. PR Updates

After creating or updating a PR, MUST add a summary comment:

<format name="comment-head">
# OpenCode AI Summary
</format>

<format name="comment-body">
**Commit:** `{commit_id}` - {commit_title}
{commit_body}

**Changes Overview:** {comments}

---
</format>

<format name="comment-foot">
*This summary was generated automatically by OpenCode.*
</format>

</step>

<step name="maintenance">

## 10. Maintenance

SHOULD synchronize PR title and body if new changes affect the PR's overall scope.

</step>

</workflow>
