---
description: commit current changes following guidelines
agent: build
---
Commit the current changes following the Git and Pull Request Guidelines in AGENTS.md.
  1. If you're on main branch, create a branch with one of the following prefixes:
     - `feat-category-*`: Used for adding new features inside `packages/` or `src/settings/`
     - `fix-category-*`: Used for fixing bugs inside `packages/` or `src/settings/`
     - `refactor-category-*`: Used for refactoring code inside `packages/` or `src/settings/`
     - `build-category-*`: Used for changing code of `src/build.py`, Justfile, or Dockerfile.
     - `ci-category-*`: Used for updating GitHub Actions, Renovate, Mergify, Release Please, or OpenCode (inside `.opencode/`) configuration.
     - `test-category-*`: Used for updating test patterns inside `tests/`.
     - `docs-category-*`: Used for documentation changes.
     - `style-category-*`: Used for code style changes that do not affect the meaning of the code.
     - `chore-category-*`: Used for other changes that don't modify src or test files.
  2. If there is already an unmerged commit at the branch, amend the changes to the commit, and reword the commit.
  3. If there isn't an unmerged commit at the branch, create a conventional commit.
  4. Pushing to upstream, and creating a draft PR if none exists. Use following template as the body of PR:
```markdown
# 🤖 **OpenCode AI Summary**

**Purpose:** {purpose_of_pr}

**Summary:** {summary_of_all_changes_against_main_branch}

---
*This summary was generated automatically by OpenCode.*
```
  5. After creating the PR or making changes to the PR, add a summary comment with the following template:
Head:
```markdown
# 🤖 **OpenCode AI Summary**
```
Body (you could duplicate the body if there are more than one commit):
```markdown
**Commit:** `{commit_id}` - {commit_title}
{commit_body}

**Changes Overview:** {comments}

---
```
Foot:
```markdown
*This summary was generated automatically by OpenCode.*
```
  6. Change the PR title and body if new changes affect them.
