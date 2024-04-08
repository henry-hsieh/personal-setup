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


if ( ! -e $HOME/.base16_theme ) then
    bash --init-file $HOME/.local/share/scripts/set_base16.sh -i -c 'base16_default-dark'
    setenv BASE16_THEME "default-dark"
else
    bash --norc -c 'source $HOME/.base16_theme'
    setenv BASE16_THEME `bash -c 'source $HOME/.base16_theme 2>&1 > /dev/null; echo $BASE16_THEME'`
    setenv BASE16_THEME "`echo $BASE16_THEME`"
endif
set autolist=ambiguous
source ~/.local/share/scripts/git-completion.tcsh
set padhour
set noding

# Set history size and file
set history=1000
set histdup=erase
set histfile = ~/.tcsh_history
set savehist=(1000 merge lock)
alias precmd "if($? == 0) history -S; history -c; history -M; source ~/.local/share/scripts/git-prompt.csh"

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

alias ll 'ls -alF'
alias la 'ls -A'
alias l  'ls -CF'

alias tmux '~/.local/share/scripts/update_display.sh;\tmux -2'
alias h 'history'
alias vim 'nvim'
alias bd 'set __bd_dir="`\bd -si \!:1`"; if ( "$__bd_dir" == "No such occurrence." ) echo "$__bd_dir"; if ( "$__bd_dir" != "No such occurrence." ) cd "$__bd_dir"; unset __bd_dir'

# Set display if the host is WSL
if ( "`uname -a`" =~ *WSL* ) then
    setenv DISPLAY `cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`:0
endif

# Source post-setup script if exist
if ( -f ~/.cshrc.post ) then
    source ~/.cshrc.post
endif
