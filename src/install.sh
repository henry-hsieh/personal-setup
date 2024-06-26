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

# Backup personal settings
function backup() {
    file=$1
    if [[ -f $file ]]; then
        /usr/bin/cp "$file" "$file~"
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

    originalsize=$(file $archive | rev | cut -d' ' -f1 | rev)
    step=100
    blocks=$(echo "$originalsize / 512 / 20 / $step" | bc)

    tar -ax --checkpoint=$step --totals \
    --checkpoint-action="exec='p=\$(echo "\$TAR_CHECKPOINT/$blocks" | bc -l);printf \"%.2f%%\r\" \$p'" \
    -f $archive -C $INSTALL_DIR
}

echo -e "Start installing:"
untar $SCRIPT_DIR/home.tar.gz

# Restore origin git name and email
git config --file $INSTALL_DIR/.config/git/config user.name  "$GIT_NAME"
git config --file $INSTALL_DIR/.config/git/config user.email "$GIT_EMAIL"

echo -e "===================================================================="
echo -e "Installation completed!\n"
echo -e "Please refer to following link for post-installation guides:"
echo -e "https://github.com/henry-hsieh/personal-setup/wiki/Environment-Setup"
echo -e "===================================================================="
