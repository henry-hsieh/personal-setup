# download_file url [output_file]
function download_file() {
  local file_name=""
  local dir_name=""
  if [[ $# -gt 1 ]]; then
    file_name="$(basename $2)"
    dir_name="$(dirname $2)"
  else
    file_name="$(basename $1)"
    dir_name="."
  fi

  if [[ ! -e "$file_name" ]]; then
    mkdir -p $dir_name
    pushd $dir_name
    if [[ -f "$file_name" ]]; then
      curl -L "$1" -z "$file_name" -o "$file_name"
    else
      curl -L "$1" -o "$file_name"
    fi
    if [[ 0 -ne $? ]]; then
      echo "Download \"$file_name\" failed"
      exit 1
    fi
    popd
  fi
}

# download_exe url [output_file]
function download_exe() {
  download_file "$@"

  if [[ $# -gt 1 ]]; then
    chmod 755 "$2"
  else
    chmod 755 "$(basename $1)"
  fi
}

# download_git_repo url [output_dir [branch_name]]
function download_git_repo() {
  local file_name=""
  local dir_name=""
  local branch_name=""
  if [[ $# -gt 2 ]]; then
    file_name="$(basename $2)"
    dir_name="$(dirname $2)"
    branch_name="$3"
  elif [[ $# -gt 1 ]]; then
    file_name="$(basename $2)"
    dir_name="$(dirname $2)"
    branch_name="master"
  else
    file_name="$(basename ${1%.git})"
    dir_name="."
    branch_name="master"
  fi

  if [[ ! -e "$file_name" ]]; then
    mkdir -p $dir_name
    pushd $dir_name
    if [[ -d "$file_name/.git/" ]]; then
      pushd "$file_name"
      git reset --hard HEAD
      git checkout $branch_name
      git pull --depth 1 origin $branch_name
      popd
    else
      rm -rf "$file_name"
      git clone "$1" --depth 1 --branch $branch_name "$file_name"
    fi
    if [[ 0 -ne $? ]]; then
      echo "Download \"$file_name\" failed"
      exit 1
    fi
    popd
  fi
}

# print_process_item string
print_process_item() {
  if [[ $# -eq 1 ]]; then
    local string="$1"
  else
    local string="print_process_item command error"
  fi
  if [[ $# -eq 1 ]]; then
    echo ""
    echo "=================================="
    echo "${string}..."
    echo "=================================="
  else
    echo ""
    echo "==================================" > /dev/stderr
    echo "$string" > /dev/stderr
    echo "==================================" > /dev/stderr
    exit 1
  fi
}
