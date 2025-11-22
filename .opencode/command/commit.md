---
description: commit current changes following guidelines
agent: build
---
Commit the current changes following the Git and Pull Request Guidelines in AGENTS.md.
  1. If you're on main branch, create a feature (`feat-category-*`), hotfix (`fix-category-*`) or refactor (`refactor-category-*`) branch.
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
