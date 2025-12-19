# Personal Setup

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE)

The **personal-setup** plugin is designed to facilitate the easy setup and maintenance of a personalized Linux environment. This tool is particularly useful for environments that are not connected to the network. The plugin includes configurations for various components such as the shell, Neovim, Tmux, and also provides the ability to build binaries with `musl-gcc` for portable usage.

## Features

- **Shell Setups**: Personalized shell configurations to enhance your command-line experience.
- **Neovim Setups**: Configurations and plugins for Neovim to optimize your text editing workflow.
- **Tmux Setups**: Configuration for Tmux to manage terminal sessions efficiently.
- **Build Binaries with musl-gcc**: Ability to build binaries with `musl-gcc` for portability.
- **Automated Release After Commit**: The plugin is configured to automatically release after each commit.

## Installation

1. Download the latest prebuilt archive and untar it:

   ```bash
   tar -xzvf personal-setup.tar.gz
   ```

2. Change into the `personal-setup` directory:

   ```bash
   cd personal-setup
   ```

3. Execute the `install.sh` script:

   ```bash
   ./install.sh /path/to/install
   ```

   Normally, the installation path will be your home directory: `$HOME`.
   If you don't want to overwrite your own home directory, you can install to somewhere else and execute following command inside Bash:

   ```bash
   HOME=/path/to/install bash
   ```

   Or inside TCSH:

   ```csh
   env HOME=/path/to/install bash
   ```

4. Refer to the [post-installation guide](https://github.com/henry-hsieh/personal-setup/wiki/Environment-Setup) in Wiki.

5. Login to your shell again.

## Development Guide

If you want to build from source or to contribute, following is the guide to do so.

### Prerequisites

- **Docker**: Ensure that Docker is installed on your system.

### Build Step

1. Execute `just build_docker` to build the docker environment.
2. Execute `just build` to build the environment in `build/output/`.
3. Execute `just release` to archive the environment into `build/personal-setup.tar.gz`.
4. **(Optional)** Execute `just test` to test the correctness of the environment.

### Organization

- `src/`: The directory contains source files.
  - `settings/`: The initial Linux environment settings. Put your preset scripts in correct hierarchy.
    - `.local/share/scripts/`: The directory contains the scripts called by `.bashrc` or `.cshrc`.
  - `build.sh`: The script to create the Linux environment.
  - `init.sh`: The script to initialize the Linux environment. Usually call the package managers to download the managed packages.
  - `install.sh`: The script to install the Linux environment. Should be included in release package.
  - `utils.sh`: The script contains some utility functions.
  - `Dockerfile`: The Docker settings. The packages required by `build.sh` should be specified in the file.
- `build/`: The directory contains the downloaded files and output of the scripts.
  - `personal-setup/`: The directory contains the installation script and the payloads, which will be archived and uploaded to GitHub Release.
    - `build_home/`: The directory contains the final Linux environment, which will be archived and becomes the payload of installation.
  - `test/`: The directory contains the decompressed files of the `personal-setup.tar.gz` for testing.
    - `home/`: The directory is used for running test patterns.
- `tests/`: The directory contains test environment settings and test patterns managed by [pytest-workflow](https://github.com/LUMC/pytest-workflow).
  - `Dockerfile`: The Docker settings for testing. The packages required by testing should be specified in the file.
- `Makefile`: Used to manage build system.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE) file for details.
