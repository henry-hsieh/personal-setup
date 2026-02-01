# Agent Guidelines for Personal Setup Repository

<context>

## Build/Lint/Test Commands

### Tool Configuration
- Tool execution time limit SHOULD be raised to 600 seconds.

### Build Commands
- `just parallel=<num_cpus> retry=0 build` - Build the environment in `build/output/`
- `just parallel=<num_cpus> retry=0 fast_fail=1 build` - Immediately stop when building process has error
- `just release` - Archive the environment into `build/personal-setup.tar.gz`
- `just build_docker` - Build the Docker image for building. MUST rebuild docker after changing `src/Dockerfile`.

### Test Commands
- `just test` - Run full test suite (builds, installs, and tests environment). You MUST run `just release` before `just test` to create release archive.
- `make -C tests <target>` - Run individual test (replace `<target>` with test name)

### Lint and Format Commands
- `ruff check && ty check` for Python script checking.
- `ruff format` for Python script formatting.
- `stylua` for Lua script formatting.

</context>

<guidelines>

## Code Style Guidelines

### Shell Scripts (Bash)
- SHOULD use `#!/usr/bin/env bash` shebang
- SHOULD use 2-space indentation
- SHOULD add comments for major sections with `##` or `#`
- SHOULD use `set -e` for strict error handling where appropriate
- MUST quote variables: `"$variable"`
- SHOULD use descriptive variable names in UPPER_SNAKE_CASE for constants
- Functions SHOULD be lowercase with underscores: `function_name()`
- SHOULD check command success with `if ! command -v ...` or `|| exit 1`

### Lua (Neovim Configuration)
- SHOULD use 2-space indentation
- SHOULD follow Neovim Lua conventions
- SHOULD use descriptive variable names in snake_case
- Tables SHOULD use consistent formatting with proper alignment
- SHOULD use `local` for variables unless global is required
- Functions: `function name() ... end` or `local function name() ... end`
- SHOULD use `pcall` for potentially failing operations
- Comments: `--` for single line, `--[[ ]]` for multi-line

### TypeScript (LSP Test)
- SHOULD use modern TypeScript features (async/await, ES6+)
- SHOULD use 2-space indentation
- SHOULD use camelCase for variables and functions
- SHOULD use PascalCase for types, interfaces, classes
- SHOULD use explicit typing with `: Type` syntax
- SHOULD use try/catch blocks for error handling
- SHOULD group imports by type (external libraries first, then local)

### General
- MUST NOT have trailing whitespace
- MUST use LF line endings
- Files MUST end with newline
- Lines SHOULD NOT exceed ~120 characters
- MUST use meaningful commit messages following conventional commits
- MUST follow existing patterns in the codebase for consistency

</guidelines>

<rules>

## Git and Pull Request Guidelines

### Branch Management
- MUST NOT commit directly to the main branch
- MUST create a new branch and open a pull request for review
- Branch names SHOULD match the commit title format (<type>-<category>-<short_summary> or <type>-<short_summary>)

### Commit Messages
- MUST use conventional commit format
- Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`, `ci`, `build`
- MAY add a category in parentheses, e.g., `feat(nvim): add new plugin`
- SHOULD examine `git log` for examples

### Amending Commits
- SHOULD squash smaller commits to previous commit when changing implementation
- MAY add additional commits for larger changes if necessary

### Pushing Changes
- MUST push to the upstream repository after creating or amending commits

### Pull Request Management
- MUST use GitHub CLI (`gh`) for creating and managing pull requests
- MUST create a new pull request and set it as draft if one does not exist
- SHOULD add comments in the pull request describing the changes made
- MUST use `cat <<EOF` syntax for handling multi-line text in PR body or comment body
- MUST remove draft status once confirmed ready for merge (Mergify handles automated merge)

### Critical Constraint
- MUST NOT commit unless explicitly instructed by the user

</rules>
