# .login

# User specific environment
set -f path=("$HOME/bin" $path:q)
set -f path=("$HOME/.local/bin" $path:q)

# Set LANG if there is no preset
if ( ! $?LANG ) then
  setenv LANG "en_US.UTF-8"
endif

# Set XDG-relative environment variables
if ( ! $?XDG_CONFIG_HOME ) then
  setenv XDG_CONFIG_HOME "$HOME/.config"
endif
if ( ! $?XDG_DATA_HOME ) then
  setenv XDG_DATA_HOME "$HOME/.local/share"
endif
if ( ! $?XDG_STATE_HOME ) then
  setenv XDG_STATE_HOME "$HOME/.local/state"
endif
if ( ! $?XDG_CACHE_HOME ) then
  setenv XDG_CACHE_HOME "$HOME/.cache"
endif

# Set display if it's empty
if ( ! $?DISPLAY ) then
  setenv DISPLAY ":0"
endif

# Java
setenv JAVA_HOME "$HOME/.local/lib/java"
setenv PATH "$JAVA_HOME/bin:$PATH"

# Rustup and Cargo
setenv RUSTUP_HOME "$HOME/.local/rustup"
setenv CARGO_HOME "$HOME/.local/cargo"
setenv PATH "$CARGO_HOME/bin:$PATH"

# Bun
setenv BUN_INSTALL "$HOME/.local/bun"
setenv BUN_INSTALL_CACHE_DIR "$HOME/.cache/bun"
setenv PATH "$BUN_INSTALL/bin:$PATH"

# Mason (Neovim package manager)
setenv PATH "${XDG_DATA_HOME}/nvim/mason/bin:$PATH"

# OpenCode
if ( -f "${XDG_CONFIG_HOME}/opencode/custom.json" ) then
  setenv OPENCODE_CONFIG "${XDG_CONFIG_HOME}/opencode/custom.json"
endif

# Delta
setenv DELTA_FEATURES "+side-by-side"

# Flag to indicate we're being sourced from .login
setenv __FROM_LOGIN 1

# Source .cshrc for interactive shells
if ( $?prompt && -f "$HOME/.cshrc" ) then
  source "$HOME/.cshrc"
endif

# Unset the flag
unsetenv __FROM_LOGIN

# Custom script for login shell
if ( -f "${XDG_CONFIG_HOME}/personal-setup/csh-custom-login.csh" ) then
  source "${XDG_CONFIG_HOME}/personal-setup/csh-custom-login.csh"
endif
