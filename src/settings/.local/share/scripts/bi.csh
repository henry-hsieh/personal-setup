# Interactively jump to a parent directory using fzf
set noglob
set __bi_pwd = `pwd -L | sed 's#/$##'`

if ("$__bi_pwd" == "") then
    echo "/"
    exit
endif

set __bi_result = `echo "$__bi_pwd" | tr '/' '\n' | awk 'BEGIN{print "/"} NF{path=path"/"$0; print path}' | head -n -1 | tac | awk '{print "["NR"] "$0}' | fzf -1 --height 40% --reverse --ansi --prompt='Jump back > ' | sed 's/^\[[0-9]*\] //'`

if ("$__bi_result" != "") then
    echo "$__bi_result"
else
    echo "."
endif
