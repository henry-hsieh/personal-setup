# Jump to a directory using only keywords.
# This command cannot be directly embedded into alias because 'else \n if' cannot be distinguished from 'else if'
set __zoxide_args = (!*)
if ("$#__zoxide_args" == 0) then
    cd ~
else
    if ("$#__zoxide_args" == 1 && "$__zoxide_args[1]" == "-") then
        cd -
    else if ("$#__zoxide_args" == 1 && -d "$__zoxide_args[1]") then
        cd "$__zoxide_args[1]"
    else
        set __zoxide_pwd = `pwd -L`
        set __zoxide_result = "`zoxide query --exclude '"'"'$__zoxide_pwd'"'"' -- $__zoxide_args`" && cd "$__zoxide_result"
    endif
endif
