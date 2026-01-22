# Get a parent directory using zoxide-like keywords with fzf fallback
set __zoxide_args = (!*)
# 1. No arguments: go back one level
if ("$#__zoxide_args" == 0) then
    echo ".."
    exit
endif

# Get current path without trailing slash
set __zoxide_pwd = `pwd -L | sed 's#/$##'`

# 2. At root: nowhere to go
if ("$__zoxide_pwd" == "") then
    echo "/"
    exit
endif

# 3. Pattern match logic: fuzzy search with all arguments
set __zoxide_pattern = `echo "$__zoxide_args" | sed "s/ /.*/g"`
# Greedy match to find at most one result.
# Training '/' is used to exclude current directory.
set __zoxide_target = `echo "$__zoxide_pwd" | rg -oi -- ".+${__zoxide_pattern}[^/]*/"`

if ("$__zoxide_target" != "") then
    echo "$__zoxide_target"
else
    # 4. Fallback to fzf
    set __zoxide_result = `echo "$__zoxide_pwd" | tr '/' '\n' | awk 'BEGIN{print "/"} NF{path=path"/"$1; print path}' | head -n -1 | tac | awk '{print "["NR"] "$0}' | fzf -1 --height 40% --reverse --ansi --prompt='Jump back > ' | sed 's/.* //'`

    if ("$__zoxide_result" != "") then
        echo "$__zoxide_result"
    else
        echo "."
    endif
endif
