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

if ( ! -e $HOME/.base16_theme ) then
    bash --init-file $HOME/.set_base16.sh -i -c 'base16_default-dark'
    setenv BASE16_THEME "default-dark"
else
    setenv BASE16_THEME `bash -c 'source $HOME/.base16_theme 2>&1 > /dev/null; echo $BASE16_THEME'`
endif
set autolist=ambiguous
source ~/.git-completion.tcsh
set padhour
set noding
alias precmd "source ~/.git-prompt.csh"

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

alias ll 'ls -alF'
alias la 'ls -A'
alias l  'ls -CF'

alias tmux '~/.update_display.sh;\tmux -2'
alias h 'history'
alias vim 'nvim'

# Set display if the host is WSL
if ( "`uname -a`" =~ *WSL* ) then
    setenv DISPLAY `cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`:0
endif

# Source post-setup script if exist
if ( -f ~/.cshrc.post ) then
    source ~/.cshrc.post
endif
