# Agent Guidelines for Personal Setup Repository

## Build/Lint/Test Commands

### Build Commands
- `make build` - Build the environment in `build/personal-setup/build_home/`
- `make release` - Archive the environment into `build/personal-setup.tar.gz`
- `make build_docker` - Build the Docker image for building

### Test Commands
- `make test` - Run full test suite (builds, installs, and tests environment)
- `make -C tests <target>` - Run individual test (replace `<target>` with test name)

### Lint Commands
- No dedicated lint command.

## Code Style Guidelines

### Shell Scripts (Bash)
- Use `#!/usr/bin/env bash` shebang
- Use 2-space indentation
- Add comments for major sections with `##` or `#`
- Use `set -e` for strict error handling where appropriate
- Quote variables: `"$variable"`
- Use descriptive variable names in UPPER_SNAKE_CASE for constants
- Functions should be lowercase with underscores: `function_name()`
- Error handling: Check command success with `if ! command -v ...` or `|| exit 1`

### Lua (Neovim Configuration)
- Use 2-space indentation
- Follow Neovim Lua conventions
- Use descriptive variable names in snake_case
- Tables use consistent formatting with proper alignment
- Use `local` for variables unless global is required
- Functions: `function name() ... end` or `local function name() ... end`
- Error handling: Use `pcall` for potentially failing operations
- Comments: Use `--` for single line, `--[[ ]]` for multi-line

### TypeScript (LSP Test)
- Use modern TypeScript features (async/await, ES6+)
- Use 2-space indentation
- camelCase for variables and functions
- PascalCase for types, interfaces, classes
- Explicit typing with `: Type` syntax
- Error handling: Use try/catch blocks
- Imports: Group imports by type (external libraries first, then local)

### General Guidelines
- No trailing whitespace
- Use LF line endings
- Files should end with newline
- Maximum line length: ~120 characters
- Use meaningful commit messages following conventional commits
- Follow existing patterns in the codebase for consistency

## Git and Pull Request Guidelines

- **Branch Management**: Never commit directly to the main branch. Always create a feature branch (e.g., `feat-category-short-summary`) or hotfix branch (e.g., `fix-category-short-summary`) and open a pull request for review. Branch names should match the commit title format.
- **Commit Messages**: Use conventional commit format. Types include `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`, `ci`. Optionally add a category in parentheses, e.g., `feat(nvim): add new plugin`. Examine `git log` for examples.
- **Amending Commits**: When changing implementation, squash the smaller commit to previous commit, or add additional commits for larger changes if necessary.
- **Pushing Changes**: After creating or amending commits, push to the upstream repository.
- **Pull Request Management**: Use GitHub CLI (`gh`) for creating and managing pull requests.
- **Creating Pull Requests**: If a pull request does not exist, create a new one and set it as draft.
- **Commenting on Changes**: Add comments in the pull request describing the changes made.
- **Handling Comment Bodies**: When you want to add/edit PR body or comment body, remember to use `cat <<EOF` syntax for handling the multi-line text.
- **Merging Process**: Once confirmed ready for merge, remove the draft status. Mergify will handle the automated merge process.
- Do not commit unless explicitly instructed.
