function b
  if test -z "$argv"
    cd ..
    return
  end

  set -l __b_pwd (string replace -r '/+$' '' -- $PWD)
  if test -z "$__b_pwd"
    cd /
    return
  end

  set -l __b_pattern (string escape --style=regex -- $argv | string join '.*')
  set -l __b_target (string match -r -i ".*"$__b_pattern"[^/]*/" -- "$__b_pwd")

  if test -n "$__b_target"
    cd "$__b_target"
  else
    echo "b: no match found" >&2
    return 1
  end
end
