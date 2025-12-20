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
  - `build.py`: The script to create the Linux environment.
  - `install.sh`: The script to install the Linux environment. Should be included in release package.
  - `Dockerfile`: The Docker settings. The packages required by `build.py` should be specified in the file.
- `build/`: The directory contains the downloaded files and output of the scripts.
  - `output/`: The directory contains the final Linux environment, which will be archived into `personal-setup.tar.gz`.
  - `test/`: The directory contains the decompressed files of the `personal-setup.tar.gz` for testing.
    - `home/`: The directory is used for running test patterns.
- `tests/`: The directory contains test scripts and configurations.
- `justfile`: Used to manage build system.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE) file for details.
