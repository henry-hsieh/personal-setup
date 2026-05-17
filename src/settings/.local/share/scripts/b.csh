# Get a parent directory matching keywords
set noglob
if ($#argv == 0) then
    echo ".."
    exit
endif

set __b_pwd = `pwd -L | sed 's#/$##'`

if ("$__b_pwd" == "") then
    echo "/"
    exit
endif

set __b_pattern = ""
set __b_sep = ""
foreach __b_arg ($argv:q)
    set __b_escaped = `printf "%s\n" "$__b_arg" | sed 's/[][\.|*+?^$(){}]/\\&/g'`
    set __b_pattern = "${__b_pattern}${__b_sep}${__b_escaped}"
    set __b_sep = ".*"
end

set __b_target = `echo "$__b_pwd" | rg -oi -- ".+${__b_pattern}[^/]*/"`

if ("$__b_target" != "") then
    echo "$__b_target"
    exit 0
else
    sh -c 'echo "b: no match found" >&2'
    exit 1
endif
