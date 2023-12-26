# Personal Setup

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE)

The **personal-setup** plugin is designed to facilitate the easy setup and maintenance of a personalized Linux environment. This tool is particularly useful for environments that are not connected to the network. The plugin includes configurations for various components such as the shell, Neovim, Tmux, and also provides the ability to build binaries with `musl-gcc` for portable usage.

## Features

- **Shell Setups**: Personalized shell configurations to enhance your command-line experience.

- **Neovim Setups**: Configurations and plugins for Neovim to optimize your text editing workflow.

- **Tmux Setups**: Configuration for Tmux to manage terminal sessions efficiently.

- **Build Binaries with musl-gcc**: Ability to build binaries with `musl-gcc` for portability.

- **Automated Release After Commit**: The plugin is configured to automatically release after each commit.

## Prerequisites

- **Docker**: Ensure that Docker is installed on your system.

## Build Step

1. Execute the `./setup.sh` script to configure your environment.

2. The environment will be archived into `personal-setup.tar.gz`.

## Installation Step

1. Untar the archive:

   ```bash
   tar -xzvf personal-setup.tar.gz
   ```

2. Change into the `personal-setup` directory:

   ```bash
   cd personal-setup
   ```

3. Execute the `install.sh` script:

   ```bash
   ./install.sh $HOME
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/henry-hsieh/personal-setup/blob/main/LICENSE) file for details.
