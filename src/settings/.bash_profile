# .bash_profile

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Set LANG if there is no preset
if [ -z "$LANG" ]; then
  export LANG="en_US.UTF-8"
fi

# Set XDG-relative environment variables
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Set display if it's empty
if [ -z "$DISPLAY" ]; then
  export DISPLAY=:0
fi

# Java
export JAVA_HOME="$HOME/.local/lib/java"
export PATH="$JAVA_HOME/bin:$PATH"

# Rustup and Cargo
export RUSTUP_HOME="$HOME/.local/rustup"
export CARGO_HOME="$HOME/.local/cargo"
export PATH="$CARGO_HOME/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.local/bun"
export BUN_INSTALL_CACHE_DIR="$HOME/.cache/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Mason (Neovim package manager)
export PATH="${XDG_DATA_HOME}/nvim/mason/bin:$PATH"

# OpenCode
if [ -f "${XDG_CONFIG_HOME}/opencode/custom.json" ]; then
  export OPENCODE_CONFIG="${XDG_CONFIG_HOME}/opencode/custom.json"
fi

# Delta
export DELTA_FEATURES="+side-by-side"

# Kernel source directory
export KERN_DIR=/usr/src/kernels/$(uname -r)

# Flag to indicate we're being sourced from .bash_profile
export __FROM_LOGIN=1

# Source .bashrc for interactive shells
if [[ $- == *i* ]]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# Custom script for login shell
if [ -f "${XDG_CONFIG_HOME}/personal-setup/bash-custom-login.bash" ]; then
  . "${XDG_CONFIG_HOME}/personal-setup/bash-custom-login.bash"
fi
