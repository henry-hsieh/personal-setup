# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
set __zoxide_pwd_old = `pwd -L`
alias __zoxide_hook 'set __zoxide_pwd_tmp = "`pwd -L`"; test "$__zoxide_pwd_tmp" != "$__zoxide_pwd_old" && zoxide add -- "$__zoxide_pwd_tmp"; set __zoxide_pwd_old = "$__zoxide_pwd_tmp"'

# Jump to a directory using only keywords.
alias __zoxide_z 'source ~/.local/share/scripts/zoxide-z.csh'

# Jump to a directory using interactive search.
alias __zoxide_zi 'set __zoxide_args = (\!*)\
set __zoxide_pwd = `pwd -L`\
set __zoxide_result = "`zoxide query --exclude '"'"'$__zoxide_pwd'"'"' --interactive -- $__zoxide_args`" && cd "$__zoxide_result"'

alias z __zoxide_z
alias zi __zoxide_zi
