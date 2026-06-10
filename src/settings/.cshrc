# .cshrc

# If not running interactively or not being sourced from .login, exit
# (skip this check when __FROM_LOGIN is set - .login runs first and sets env vars)
if ( ! $?prompt || ($?loginsh && ! $?__FROM_LOGIN) ) then
  exit 0
endif

# Set colorscheme
tinty init

set autolist=ambiguous
source "${XDG_DATA_HOME}/scripts/git-completion.tcsh"
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
endif

alias ll 'ls -alF'
alias la 'ls -A'
alias l  'ls -CF'

alias h 'history'
alias vi  'vim'
alias n   'nvim'
alias nn  'nvim -u NONE'
alias bat "bat --theme='base16-256'"
setenv EDITOR 'nvim'

# Bun alias
alias bunx 'bun x'

# yazi
alias y 'set tmp=`mktemp -t yazi-cwd.XXXXXX`; \
        yazi \!* --cwd-file="$tmp"; \
        set cwd="`tr -d '\''\0'\'' < $tmp`"; \
        if ("$cwd" != "") cd "$cwd"; \
        /usr/bin/rm -f "$tmp"'

# b: jump to a parent directory matching keywords
alias b 'set __b_target = `$0 -f "${XDG_DATA_HOME}/scripts/b.csh" \!*` && cd "$__b_target" && unset __b_target'

# bi: interactively jump to a parent directory using fzf
alias bi 'set __bi_target = `$0 -f "${XDG_DATA_HOME}/scripts/bi.csh"` && cd "$__bi_target" && unset __bi_target'

# zoxide
source "${XDG_DATA_HOME}/scripts/zoxide.csh"

# lazygit wrapper
alias lazygit 'env DELTA_FEATURES= lazygit'

# Set precmd
alias precmd 'history -S; history -c; history -M; source "${XDG_DATA_HOME}/scripts/git-prompt.csh"; __zoxide_hook; eval `direnv export tcsh`'

# Custom script for subshell
if ( -f "${XDG_CONFIG_HOME}/personal-setup/csh-custom.csh" ) then
  source "${XDG_CONFIG_HOME}/personal-setup/csh-custom.csh"
endif
