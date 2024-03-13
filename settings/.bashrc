# .bashrc

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source pre-setup script if exist
if [ -f ~/.bashrc.pre ]; then
    . ~/.bashrc.pre
fi

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

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export KERN_DIR=/usr/src/kernels/$(uname -r)

# Set display if the host is WSL
case "$(uname -a)" in
    *WSL*)
        export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
        ;;
    *)
        if [ -z "$DISPLAY" ]; then # Not from SSH
            export DISPLAY=:0
        fi
        ;;
esac

if [ -z "$VIM" ]; then # Not from Neovim terminal
  . $HOME/.set_base16.sh
  if [ ! -L $HOME/.base16_theme ]; then # If base16-shell is not called
      base16_default-dark
  fi
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

# Put bash completion at first
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi
source ~/.git-prompt.sh
source ~/.git-completion.bash
source ~/.bat-completion.bash
source ~/.fzf-completion.bash
source ~/.fzf-key-bindings.bash
source ~/.fd-completion.bash
source ~/.rg-completion.bash

set_prompt()
{
    local txtreset='$(tput sgr0)'
    local txtbold='$(tput bold)'
    local txtblack='$(tput setaf 0)'
    local txtred='$(tput setaf 1)'
    local txtgreen='$(tput setaf 2)'
    local txtyellow='$(tput setaf 3)'
    local txtblue='$(tput setaf 4)'
    local txtpurple='$(tput setaf 5)'
    local txtcyan='$(tput setaf 6)'
    local txtwhite='$(tput setaf 7)'
    PS1="\[$txtbold\]\[$txtpurple\]\D{%m/%d %H:%M}\[$txtgreen\] "
    PS1+="\u@\h \[$txtcyan\]${PWD}"
    PS1+="\[$txtyellow\]$(__git_ps1 ' (%s)')"
    PS1+="\n\[$txtblue\]└─ \$ ▶\[$txtreset\]\[$txtwhite\] "
    PS2="\[$txtbold\]\[$txtblue\]└─ \$ ▶\[$txtreset\]\[$txtwhite\] "
    if ! [ -z $TMUX ]; then
        export DISPLAY=$(\tmux show-env | sed -n 's/^DISPLAY=//p')
    fi
}
PROMPT_COMMAND='set_prompt'

alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias tmux='~/.update_display.sh;tmux -2'
alias vim='nvim'

# Source post-setup script if exist
if [ -f ~/.bashrc.post ]; then
    . ~/.bashrc.post
fi

