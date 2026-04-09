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

You can add custom shell commands or environment variables by creating the following files in your home directory:

- **Bash**:
  - `~/.bashrc.pre`: Executed at the beginning of `.bashrc`.
  - `~/.bashrc.post`: Executed at the end of `.bashrc`.
- **Tcsh**:
  - `~/.cshrc.pre`: Executed at the beginning of `.cshrc`.
  - `~/.cshrc.post`: Executed at the end of `.cshrc`.

### Neovim Customization

User-specific Neovim configurations can be placed in `~/.config/nvim/lua/custom/`.

- **General Settings**: Create `~/.config/nvim/lua/custom/config.lua`. The module should return a table of options to override defaults in `~/.config/nvim/lua/config/defaults.lua`.
- **Plugins**: Add custom plugins by creating `.lua` files in the `~/.config/nvim/lua/custom/plugins/` directory. Each file should return a `lazy.nvim` specification of plugins.

### OpenCode Customization

To configure OpenCode, create `~/.config/opencode/custom.json`. The `OPENCODE_CONFIG` environment variable is automatically set to this path if the file exists.

## Development Guide

If you want to build from source or to contribute, following is the guide to do so.

### Prerequisites

- **Docker**: Docker is used for building the environment.
- **Just**: All build and test commands are written in [just](https://just.systems/). You can manually install it, or this package is included in personal setup.
- **Rsync** for fast test: Fast test uses rsync to copy built environment to test folder.

### Build Step

1. Execute `just build_docker` to build the Docker environment.
2. Execute `just build` to build the environment in `build/output/`.
3. **(Optional)** Execute `just test_fast` to fast test the correctness of the environment.
4. Execute `just release` to archive the environment into `build/personal-setup.xz.sh`.
5. **(Optional)** Execute `just test_clean=1 test` to test self-extracted function of `build/personal-setup.xz.sh` and the correctness of the environment.

### Organization

- `src/`: The directory contains source files.
  - `settings/`: The initial Linux environment settings. Put your preset scripts in correct hierarchy.
    - `.local/share/scripts/`: The directory contains the scripts called by `.bashrc` or `.cshrc`.
      - `post-install.sh`: The script to call after installing the Linux environment
  - `build.py`: The script to create the Linux environment.
  - `pre-install.sh`: The script to call before installing the Linux environment.
  - `Dockerfile`: The Docker settings. The packages required by `build.py` should be specified in the file.
- `build/`: The directory contains the downloaded files and output of the scripts.
  - `output/`: The directory contains the final Linux environment, which will be compressed to self-extracted archive inside `personal-setup.xz.sh`.
  - `test/`: The directory is used for running test patterns.
- `tests/`: The directory contains test scripts and configurations.
- `packages/`: The directory contains package definitions.
- `justfile`: Used to manage the build system.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE) file for details.
