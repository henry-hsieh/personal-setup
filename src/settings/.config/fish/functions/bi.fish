function bi
  set -l __b_pwd (string replace -r '/+$' '' -- $PWD)
  if test -z "$__b_pwd"
    cd /
    return
  end

  set -l __b_parts (string split / "$__b_pwd")
  set -l __b_paths
  set -l __b_accum ""
  for part in $__b_parts
    if test -n "$part"
      set __b_accum "$__b_accum/$part"
      set -a __b_paths "$__b_accum"
    end
  end

  if test (count $__b_paths) -gt 0
    set -e __b_paths[-1]
  end
  set __b_paths / $__b_paths

  set -l __b_result
  if test (count $__b_paths) -gt 0
    set __b_paths $__b_paths[-1..1]
    set __b_result (
      for i in (seq (count $__b_paths))
        printf "[%d] %s\n" (math $i - 1) "$__b_paths[$i]"
      end | fzf -1 --height 40% --reverse --ansi --prompt='Jump back > ' | string replace -r '^\[\d+\] ' ''
    )
  end

  if test -n "$__b_result"
    cd "$__b_result"
  end
end
