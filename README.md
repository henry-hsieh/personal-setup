# Personal Setup

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE)

The **personal-setup** tool is designed to facilitate the easy setup and maintenance of a personalized Linux environment. This tool is particularly useful for environments that are not connected to the network. The tool includes configurations for various components such as the shell, Neovim, Tmux, and builds portable binaries from source.

## Features

- **Shell Setups**: Personalized shell configurations to enhance your command-line experience.
- **Neovim Setups**: Configurations and plugins for Neovim to optimize your text editing workflow.
- **Tmux Setups**: Configuration for Tmux to manage terminal sessions efficiently.
- **Portable Binaries**: Builds binaries from source for portability.
- **Automated Releases**: Automatically creates releases based on conventional commits.

## Installation

1. Download the latest prebuilt installation package and install it. The target system should have `xz` for embedded archive extraction.

   ```bash
   chmod +x personal-setup.xz.sh && ./personal-setup.xz.sh --target /path/to/install
   ```

   Normally, the installation path will be your home directory: `$HOME`.
   If you don't want to overwrite your own home directory, you can install to somewhere else and execute following command inside Bash:

   ```bash
   HOME=/path/to/install bash
   ```

   Or inside Tcsh:

   ```csh
   env HOME=/path/to/install bash
   ```

2. Refer to the [post-installation guide](https://github.com/henry-hsieh/personal-setup/wiki/Environment-Setup) in Wiki.

3. Login to your shell again.

## Customization

The environment supports customization through specific configuration files.

### Shell Customization

You can add custom shell commands or environment variables by creating the following files:

- **Bash**:
  - `${XDG_CONFIG_HOME}/personal-setup/bash-custom.bash`: Executed at the end of `.bashrc` (subshell).
  - `${XDG_CONFIG_HOME}/personal-setup/bash-custom-login.bash`: Executed at the end of `.bash_profile` (login shell).
- **Tcsh**:
  - `${XDG_CONFIG_HOME}/personal-setup/csh-custom.csh`: Executed at the end of `.cshrc` (subshell).
  - `${XDG_CONFIG_HOME}/personal-setup/csh-custom-login.csh`: Executed at the end of `.login` (login shell).
- **Fish**: Fish natively supports customization through standard paths:
  - `${XDG_CONFIG_HOME}/fish/conf.d/*.fish`: Auto-loaded configuration snippets.
  - `${XDG_CONFIG_HOME}/fish/functions/*.fish`: Function definitions (loaded on demand).

By default, `XDG_CONFIG_HOME` is set to `~/.config`.


### Git Customization

- `${XDG_CONFIG_HOME}/git/custom.gitconfig`: Included via `[include]` in the global git config.

### Tmux Customization

- `${XDG_CONFIG_HOME}/tmux/custom.conf`: Sourced at the end of `tmux.conf`.
### Neovim Customization

User-specific Neovim configurations can be placed in `${XDG_CONFIG_HOME}/nvim/lua/custom/`.

- **General Settings**: Create `${XDG_CONFIG_HOME}/nvim/lua/custom/config.lua`. The module should return a table of options to override defaults in `${XDG_CONFIG_HOME}/nvim/lua/config/defaults.lua`.
- **Plugins**: Add custom plugins by creating `.lua` files in the `${XDG_CONFIG_HOME}/nvim/lua/custom/plugins/` directory. Each file should return a `lazy.nvim` plugin specification.
- **Tree-sitter**: Create `${XDG_CONFIG_HOME}/nvim/lua/custom/treesitter.lua` to extend Tree-sitter configuration.

#### Feature Toggles

You can toggle features by overriding the `features` table in your custom config:

```lua
-- ${XDG_CONFIG_HOME}/nvim/lua/custom/config.lua
return {
  features = {
    copilot = false,        -- Disable Copilot/AI suggestions
    ai_cli = false,         -- Disable AI CLI (sidekick)
    linting = false,        -- Disable nvim-lint
    format_on_save = true,  -- Enable auto-format on save
  },
}
```

### OpenCode Customization

To configure OpenCode, create `${XDG_CONFIG_HOME}/opencode/custom.json`. The `OPENCODE_CONFIG` environment variable is automatically set to this path if the file exists.

## Development Guide

If you want to build from source or to contribute, following is the guide to do so.

### Prerequisites

- **Docker**: Docker is used for building the environment.
- **Just**: All build and test commands are written in [just](https://just.systems/). You must install it to build from source.
- **Rsync**: Required for the `just test_fast` command.

### Build Step

1. Execute `just build_docker` to build the Docker environment.
2. Execute `just build` to build the environment in `build/output/`.
3. **(Optional)** Execute `just test_fast` to fast test the correctness of the environment.
4. Execute `just release` to archive the environment into `build/personal-setup.xz.sh`.
5. **(Optional)** Execute `just test_clean=1 test` to test the self-extraction functionality of `build/personal-setup.xz.sh` and the correctness of the environment.

### Organization

- `src/`: The directory contains source files.
  - `settings/`: The initial Linux environment settings. Put your preset scripts in correct hierarchy.
    - `.local/share/scripts/`: The directory contains the scripts called by `.bashrc` or `.cshrc`.
      - `post-install.sh`: The script that runs after the environment archive is extracted.
  - `build.py`: The script to create the Linux environment.
  - `pre-install.sh`: The script that runs before the environment archive is extracted.
  - `Dockerfile`: The Docker settings. The packages required by `build.py` should be specified in the file.
- `build/`: The directory contains the downloaded files and output of the scripts.
  - `output/`: The directory contains the final Linux environment, which will be compressed to self-extracted archive inside `personal-setup.xz.sh`.
-  `test/`: The directory where the built environment is deployed for testing.
- `tests/`: The directory contains test scripts and configurations.
- `packages/`: The directory contains package definitions.
- `justfile`: Used to manage the build system.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE) file for details.
