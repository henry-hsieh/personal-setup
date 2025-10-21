#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage: $0 /path/to/install"
    exit
fi

INSTALL_DIR=$1
SCRIPT_DIR=$(dirname $(realpath $0))
if [[ -f $INSTALL_DIR/.local/bin/tmux && $($INSTALL_DIR/.local/bin/tmux list-session) != "" ]]; then
    echo "Please close all tmux sessions to proceed"
    exit
fi

# Create installation path if it does not exist
mkdir -p $INSTALL_DIR

# Backup current git name and email
GIT_NAME=$(git config --global --get user.name)
GIT_EMAIL=$(git config --global --get user.email)

# Backup installation path permission
PERMISSION=$(stat -c '%a' $INSTALL_DIR)

# Backup personal settings
function backup() {
    file=$1
    if [[ -f $file ]]; then
        cp "$file" "$file~"
    fi
}

backup $INSTALL_DIR/.bashrc
backup $INSTALL_DIR/.cshrc
backup $INSTALL_DIR/.config/git/config
backup $INSTALL_DIR/.config/tmux/tmux.conf
backup $INSTALL_DIR/.config/nvim/init.lua

# Install environment
function untar() {
    archive="$1"

    if command -v pv &> /dev/null; then
        pv $archive | tar -zxf - -C $INSTALL_DIR
    else
        originalsize=$(gzip -l $archive | tail -1 | awk -F' ' '{print $2}')
        step=100
        blocks=$(($originalsize / 512 / 20 / $step))
        tar -zx --checkpoint=$step --totals \
            --checkpoint-action=exec="awk \"BEGIN { printf \\\"%.2f%%\r\\\", \$TAR_CHECKPOINT/$blocks }\"" \
            -f $archive -C $INSTALL_DIR
    fi
}

echo -e "Start installing:"
rm -rf $INSTALL_DIR/.local/share/nvim/runtime
untar $SCRIPT_DIR/home.tar.gz
echo -e "Clean plugins..."
cd $INSTALL_DIR/.local/share/nvim/lazy
for d in */ ; do
  pushd $d > /dev/null
  git reset --hard HEAD > /dev/null
  git clean -fdq > /dev/null
  popd > /dev/null
done

# Restore origin git name and email
git config --file $INSTALL_DIR/.config/git/config user.name  "$GIT_NAME"
git config --file $INSTALL_DIR/.config/git/config user.email "$GIT_EMAIL"

# Restore installation path permission
chmod $PERMISSION $INSTALL_DIR

echo -e "===================================================================="
echo -e "Installation completed!\n"
echo -e "Please refer to following link for post-installation guides:"
echo -e "https://github.com/henry-hsieh/personal-setup/wiki/Environment-Setup"
echo -e "===================================================================="
