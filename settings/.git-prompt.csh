set     red="%{\033[1;31m%}"
set   green="%{\033[1;32m%}"
set  yellow="%{\033[1;33m%}"
set    blue="%{\033[1;34m%}"
set magenta="%{\033[1;35m%}"
set    cyan="%{\033[1;36m%}"
set   white="%{\033[0;37m%}"
set     end="%{\033[0m%}"

setenv GIT_BRANCH_CMD "sh -c 'git branch --no-color 2> /dev/null' | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'"
set prompt="${magenta}%W/%D %T ${green}%n@%m ${cyan}${cwd} ${yellow}`$GIT_BRANCH_CMD` \n${blue}└─ \044 ▶${white}${end} "
set prompt2="${blue}└─ \044 ▶${white}${end} "
if ( $?TMUX ) then
    setenv DISPLAY `\tmux show-env | sed -n 's/^DISPLAY=//p'`
endif

unset red green yellow blue magenta cyan yellow white end
