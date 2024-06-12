#!/usr/bin/env bash

# Skip update outside tmux
if [ -z $TMUX ]; then
  exit
fi

tmux list-panes -s -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}" | \
  while read pane_process
  do
    IFS=' ' read -ra pane_process <<< "$pane_process"
    suspend=0
    id="${pane_process[0]}"
    process="${pane_process[1]}"
    if [[ "$process" != *"sh" && "$process" != "docker" ]]; then
      # suspend current process
      tmux send-keys -t $id C-z
      shell=$(tmux list-panes -s -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}" | grep $id | awk '{ print $2 }')
      suspend=1
    else
      shell=$process
    fi
    if [[ "$shell" == "zsh" || "$shell" == "bash" ]]; then
      tmux send-keys -t $id C-c
      for var in "$@"; do
        if [[ "$(tmux show-env -g | grep -e ^$var=)" == "" ]]; then
          tmux send-keys -t $id "unset $var" Enter
        else
          tmux send-keys -t $id "export $(tmux show-env -g $var)" Enter
        fi
      done
    elif [[ "$shell" == "csh" || "$shell" == "tcsh" ]]; then
      tmux send-keys -t $id C-c
      for var in "$@"; do
        if [[ "$(tmux show-env -g | grep -e ^$var=)" == "" ]]; then
          tmux send-keys -t $id "unsetenv $var" Enter
        else
          tmux send-keys -t $id "setenv $(tmux show-env -g $var | sed -n 's/=/ /p')" Enter
        fi
      done
    fi
    if [[ $suspend == 1 ]]; then
      tmux send-keys -t $id "fg" Enter
      if [[ "$shell" == *"vim"* ]]; then
        tmux send-keys -t $id Escape
        for var in "$@"; do
        if [[ "$(tmux show-env -g | grep -e ^$var=)" == "" ]]; then
            tmux send-keys -t $id ":unlet \$$var" Enter
          else
            tmux send-keys -t $id ":let \$$(tmux show-env -g $var | sed -n 's/=/"/p')\"" Enter
          fi
        done
      fi
    fi
  done
