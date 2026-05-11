if status is-interactive
  # Commands to run in interactive sessions can go here
  set -g fish_greeting ''
  set -g fish_transient_prompt 1
  set -g EDITOR nvim
  direnv hook fish | source

  # Keybindings
  fzf_configure_bindings --directory=ctrl-shift-f --variables=ctrl-alt-v
  bind -M insert \cf forward-word
  bind \cf forward-word
end
