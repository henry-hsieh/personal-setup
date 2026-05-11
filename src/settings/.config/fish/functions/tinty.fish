function tinty --wraps=tinty --description="Tinty wrapper to apply shell environment variables"
  # Create a temporary file to track modifications
  set -l newer_file (mktemp)

  # Use 'command' to call the actual binary and bypass the function,
  # preventing an infinite loop. $argv passes all arguments.
  set -l tinty_config_path "$HOME/.config/tinted-theming/tinty/fish.toml"
  if set -q XDG_CONFIG_HOME; and test -n "$XDG_CONFIG_HOME"
    set tinty_config_path "$XDG_CONFIG_HOME/tinted-theming/tinty/fish.toml"
  end

  if contains -- "-c" $argv; or contains -- "--config" $argv
    command tinty $argv
  else
    command tinty -c "$tinty_config_path" $argv
  end
  set -l tinty_status $status

  set -l subcommand $argv[1]

  if test "$subcommand" = "apply"; or test "$subcommand" = "init"
    # Handle the default fallback for XDG_DATA_HOME
    set -l tinty_data_dir "$HOME/.local/share/tinted-theming/tinty"
    if set -q XDG_DATA_HOME; and test -n "$XDG_DATA_HOME"
      set tinty_data_dir "$XDG_DATA_HOME/tinted-theming/tinty"
    end

    # Find and source updated scripts
    find "$tinty_data_dir" -maxdepth 1 \( -type f -o -type l \) -name "*.fish" -newer "$newer_file" -print0 2>/dev/null | while read -l -z script
      source "$script"
    end
  end

  # Clean up the temp file
  rm -f "$newer_file"

  # Return actual tinty status
  return $tinty_status
end
