# .bashrc

# If not from login, source login script first
[ -z "$__FROM_LOGIN" ] && source "$HOME/.bash_profile" && return

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *)   return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Set display if it's empty
if [ -z "$DISPLAY" ]; then
  export DISPLAY=:0
fi

tinty() {
  local newer_file
  newer_file=$(mktemp)
  # Ensure temporary file is removed on function exit
  trap '\rm -f -- "$newer_file"' RETURN

  command tinty "$@"
  subcommand="$1"

  if [ "$subcommand" = "apply" ] || [ "$subcommand" = "init" ]; then
    tinty_data_dir="${XDG_DATA_HOME}/tinted-theming/tinty"

    while read -r script; do
      # shellcheck disable=SC1090
      . "$script"
    done < <(find "$tinty_data_dir" -maxdepth 1 \( -type f -o -type l \) -name "*.sh" -newer "$newer_file")

    unset tinty_data_dir
  fi

  unset subcommand
}

if [ -n "$(command -v 'tinty')" ] && [ -z "$NVIM" ]; then
  tinty "init" > /dev/null
fi

# Use ~~ as the trigger sequence instead of the default **
#export FZF_COMPLETION_TRIGGER='~~'

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    vim)          fzf "$@" --preview 'bat --style=numbers --color=always --line-range :500 {}' ;;
    *)            fzf "$@" ;;
  esac
}

# FZF Tab Completion
stty -ixon # Disable Xon
bind -x '"\C-q": fzf_bash_completion'

# Put bash completion at first
if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
fi
source ${XDG_DATA_HOME}/scripts/git-prompt.sh
source ${XDG_DATA_HOME}/scripts/fzf-completion.bash
source ${XDG_DATA_HOME}/scripts/fzf-key-bindings.bash
source ${XDG_DATA_HOME}/scripts/fzf-bash-completion.sh

set_prompt() {
  local txtreset='\[\e[0m\]'
  local txtbold='\[\e[1m\]'
  local txtblack='\[\e[30m\]'
  local txtred='\[\e[31m\]'
  local txtgreen='\[\e[32m\]'
  local txtyellow='\[\e[33m\]'
  local txtblue='\[\e[34m\]'
  local txtpurple='\[\e[35m\]'
  local txtcyan='\[\e[36m\]'
  local txtwhite='\[\e[37m\]'
  local txtlblack='\[\e[90m\]'
  local txtlred='\[\e[91m\]'
  local txtlgreen='\[\e[92m\]'
  local txtlyellow='\[\e[93m\]'
  local txtlblue='\[\e[94m\]'
  local txtlpurple='\[\e[95m\]'
  local txtlcyan='\[\e[96m\]'
  local txtlwhite='\[\e[97m\]'
  PS1="$txtbold$txtpurple\D{%m/%d %H:%M}$txtgreen "
  PS1+="\u@\h $txtcyan${PWD}"
  PS1+="$txtyellow\$(__git_ps1 ' (%s)')"
  PS1+="\n$txtlblack"$'\u2570\u2500'$txtlgreen$'\u276f'"$txtreset$txtwhite "
  PS2="$txtlblack"$'\u2570\u2500'$txtlgreen$'\u276f'"$txtreset$txtwhite "
  if [[ -n "$TMUX" ]]; then
    # 1. Fetch current tmux environment state
    local current_tmux_envs
    current_tmux_envs=$(tmux show-env -g 2>/dev/null)

    # 2. Has anything actually changed since the last prompt?
    # If the string is exactly the same, skip the entire loop!
    if [[ "$current_tmux_envs" != "$_LAST_TMUX_ENV" ]]; then

      # Save the new state to cache for next time
      _LAST_TMUX_ENV="$current_tmux_envs"

      # Cache the update list names if we haven't already
      if [[ -z "$_CACHED_ENV_UPDATE_LIST" ]]; then
        local raw_list
        raw_list=$(tmux show-options -g @env_update_list 2>/dev/null)
        local parsed_list="${raw_list#*@env_update_list}"
        _CACHED_ENV_UPDATE_LIST="${parsed_list//\"/}"
        [[ -z "$_CACHED_ENV_UPDATE_LIST" ]] && _CACHED_ENV_UPDATE_LIST="__EMPTY__"
      fi

      # Run the configuration loop ONLY when a change is detected
      if [[ "$_CACHED_ENV_UPDATE_LIST" != "__EMPTY__" ]]; then
        for var in $_CACHED_ENV_UPDATE_LIST; do
          if [[ $'\n'"$current_tmux_envs" =~ $'\n'"$var=" ]]; then
            export "$(tmux show-env -g "$var")"
          else
            unset "$var"
          fi
        done
      fi
    fi
  fi
}
PROMPT_COMMAND="history -a; history -n; set_prompt"

alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias vi='vim'
alias n='nvim'
alias nn='nvim -u NONE'
alias bat="bat --theme='base16-256'"
export EDITOR='nvim'

# Bun alias
alias bunx='bun x'

# yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  /usr/bin/env rm -f -- "$tmp"
}

# b: jump to a parent directory matching keywords
function b() {
  if [[ -z "$1" ]]; then
    builtin cd ..
    return
  fi

  local __b_pwd="${PWD%/}"

  if [[ -z "$__b_pwd" ]]; then
    builtin cd /
    return
  fi

  local __b_pattern=""
  local __b_sep=""
  for arg in "$@"; do
    local __b_escaped=$(sed 's/[][\.|*+?^$(){}]/\\&/g' <<< "$arg")
    __b_pattern+="${__b_sep}${__b_escaped}"
    __b_sep=".*"
  done
  local __b_target=$(rg -oi -- ".+${__b_pattern}[^/]*/" <<< "$__b_pwd")

  if [[ -n "$__b_target" ]]; then
    builtin cd "$__b_target"
  else
    echo "b: no match found" >&2
    return 1
  fi
}

# bi: interactively jump to a parent directory using fzf
function bi() {
  local __bi_pwd="${PWD%/}"

  if [[ -z "$__bi_pwd" ]]; then
    builtin cd /
    return
  fi

  local __bi_result=$(echo "$__bi_pwd" | tr '/' '\n' | awk 'BEGIN{print "/"} NF{path=path"/"$0; print path}' | head -n -1 | tac | awk '{print "["NR"] "$0}' | fzf -1 --height 40% --reverse --ansi --prompt='Jump back > ' | sed 's/^\[[0-9]*\] //')

  [[ -n "$__bi_result" ]] && builtin cd "${__bi_result}"
}

# Lazy load zoxide and direnv
function z() {
  unset -f z cd
  eval "$(zoxide init bash)"
  eval "$(direnv hook bash)"
  z "$@"
}

function cd() {
  unset -f z cd
  eval "$(zoxide init bash)"
  eval "$(direnv hook bash)"
  builtin cd "$@"
}

# lazygit wrapper
alias lazygit="env DELTA_FEATURES= lazygit"

# Custom script for subshell
if [ -f "${XDG_CONFIG_HOME}/personal-setup/bash-custom.bash" ]; then
  . "${XDG_CONFIG_HOME}/personal-setup/bash-custom.bash"
fi
