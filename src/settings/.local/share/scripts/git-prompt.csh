set    reset="%{\033[0m%}"
set     bold="%{\033[1m%}"
set  purple="%{\033[0;35m%}"
set   green="%{\033[0;32m%}"
set  yellow="%{\033[0;33m%}"
set    cyan="%{\033[0;36m%}"
set lblack="%{\033[0;90m%}"
set lgreen="%{\033[0;92m%}"
set  white="%{\033[0;37m%}"
set corner="`printf '\xe2\x95\xb0\xe2\x94\x80'`"
set arrow="`printf '\xe2\x9d\xaf'`"

setenv GIT_BRANCH_CMD "sh -c 'git branch --no-color 2> /dev/null' | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'"
set prompt="${bold}${purple}%W/%D %T ${green}%n@%m ${cyan}%~ ${yellow}\`$GIT_BRANCH_CMD\` \n${lblack}${corner}${lgreen}${arrow}${reset}${white} "
set prompt2="${lblack}${corner}${lgreen}${arrow}${reset}${white} "
if ( $?TMUX ) then
    setenv DISPLAY `\tmux show-env | sed -n 's/^DISPLAY=//p'`
endif

unset reset bold purple green yellow cyan lblack lgreen white corner arrow
