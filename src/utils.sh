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

# get_openjdk_download_url version arch
get_openjdk_download_url() {
  local version="$1"
  local arch="$2"

  # Initialize download url list
  local download_url_list=""

  # Retrieve the HTML content of the JDK archive page
  local html_content=$(curl -s "https://jdk.java.net/archive/")

  # Extract the list of non-archive versions and generate URLs
  local page_list=$(echo "$html_content" | grep 'GA Releases' | grep -oP '(?<=href=")[^"]+' | grep -oP '\.\./\d+' | grep -oP '\d+' | sed 's/^/https:\/\/jdk.java.net\//' | sed 's/$/\//')

  # Add JDK archive page into download page list
  page_list="${page_list} https://jdk.java.net/archive/"

  # Iterate through each download page
  for url in $page_list; do
    # Retrieve the HTML content of the page
    html_content=$(curl -s "$url")

    # Extract and append the list of download URLs
    download_url_list="$download_url_list $(echo "$html_content" | grep 'href' | grep -v 'sha256' | grep -e 'https:\/\/download.java.net\/' | grep -oP '(?<=href=")[^"]+')"
  done

  # Extract the download URL for the specified version and architecture
  local download_url=$(echo "$download_url_list" | grep "openjdk-${version}_${arch}" | head -n 1)

  # Print the download URL
  echo "$download_url"
}

# print_process_item string [mode]
print_process_item() {
  if [[ $# -eq 1 ]]; then
    local mode=0
    local string="$1"
  elif [[ $# -eq 2 ]]; then
    local mode=$2
    local string="$1"
  else
    local mode=2
    local string="print_process_item command error"
  fi
  if [[ $mode -eq 0 ]]; then
    echo ""
    echo "=================================="
    echo "${string}..."
    echo "=================================="
  elif [[ $mode -eq 1 ]]; then
    echo ""
    echo "==================================" | tee /dev/stderr
    echo "${string}..." | tee /dev/stderr
    echo "==================================" | tee /dev/stderr
  else
    echo ""
    echo "==================================" > /dev/stderr
    echo "$string" > /dev/stderr
    echo "==================================" > /dev/stderr
    exit $mode
  fi
}
