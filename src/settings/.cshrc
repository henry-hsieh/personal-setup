# .cshrc

# User specific environment
set -f path=("$HOME/bin" $path:q)
set -f path=("$HOME/.local/bin" $path:q)

# If not running interactively, don't do anything
if ( ! $?prompt ) then
    exit 0
endif

# Source pre-setup script if exist
if ( -f ~/.cshrc.pre ) then
    source ~/.cshrc.pre
endif

# Set LANG if there is no preset
if ( ! $?LANG ) then
    setenv LANG "en_US.UTF-8"
endif

# Set colorscheme
tinty init

set autolist=ambiguous
source ~/.local/share/scripts/git-completion.tcsh
set padhour
set noding

# Set history size and file
set history=1000
set histdup=erase
set histfile = ~/.tcsh_history
if ( -e "$histfile.lock" ) then
    rm -rf $histfile.lock
endif
set savehist=(1000 merge lock)

alias mv 'mv -i'
alias cp 'cp -i'
alias rm 'rm -i'

if ( -x /usr/bin/dircolors ) then
    test -r ~/.dircolors && eval "`dircolors -c ~/.dircolors`" || eval "`dircolors -c`"
    alias ls 'ls --color=auto'

    alias grep 'grep --color=auto'
    alias fgrep 'fgrep --color=auto'
    alias egrep 'egrep --color=auto'
endif

# Java
setenv JAVA_HOME "$HOME/.local/lib/java"
setenv PATH "$JAVA_HOME/bin:$PATH"

# Rustup and Cargo
setenv RUSTUP_HOME "$HOME/.local/rustup"
setenv CARGO_HOME "$HOME/.local/cargo"
setenv PATH "$CARGO_HOME/bin:$PATH"

# OpenCode
if ( -f "$HOME/.config/opencode/custom.json" ) then
  setenv OPENCODE_CONFIG "$HOME/.config/opencode/custom.json"
endif

alias ll 'ls -alF'
alias la 'ls -A'
alias l  'ls -CF'

alias h 'history'
alias vim 'nvim'
alias vi  'nvim'
alias v   'nvim'
alias bat "bat --theme='base16-256'"
alias jq  'yq'
setenv EDITOR 'nvim'

# zoxide
source ~/.local/share/scripts/zoxide.csh

# Set display if it's empty
if ( ! $?DISPLAY ) then
    setenv DISPLAY ":0"
endif

# yazi
alias y 'set tmp=`mktemp -t yazi-cwd.XXXXXX`; \
        yazi \!* --cwd-file="$tmp"; \
        set cwd="`tr -d '\''\0'\'' < $tmp`"; \
        if ("$cwd" != "") cd "$cwd"; \
        /usr/bin/rm -f "$tmp"'

# Source post-setup script if exist
if ( -f ~/.cshrc.post ) then
    source ~/.cshrc.post
endif

# Set precmd
alias precmd 'history -S; history -c; history -M; source ~/.local/share/scripts/git-prompt.csh; __zoxide_hook'
