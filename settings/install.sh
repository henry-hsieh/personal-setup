#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage: $0 /path/to/install"
    exit
fi
if ! [[ -d $1 ]]; then
    echo "Path $1 not found"
    exit
fi

SCRIPT_DIR=$(dirname $(realpath $0))
if [[ $($SCRIPT_DIR/.local/bin/tmux list-session) != "" ]]; then
    echo "Please close all tmux sessions to proceed"
    exit
fi

# Copy directories
rsync -av $SCRIPT_DIR/.config $1
rsync -av $SCRIPT_DIR/.fonts $1
rsync -av $SCRIPT_DIR/.local $1
rsync -av $SCRIPT_DIR/.tmux $1

# Backup current git name and email
GIT_NAME=$(git config --global --get user.name)
GIT_EMAIL=$(git config --global --get user.email)

# Copy files
cp -f --backup $SCRIPT_DIR/.bashrc $1
cp -f --backup $SCRIPT_DIR/.cshrc $1
cp -f          $SCRIPT_DIR/.bat-completion.bash $1
cp -f          $SCRIPT_DIR/.fd-completion.bash $1
cp -f          $SCRIPT_DIR/.fzf-completion.bash $1
cp -f          $SCRIPT_DIR/.fzf-key-bindings.bash $1
cp -f          $SCRIPT_DIR/.git-completion.bash $1
cp -f          $SCRIPT_DIR/.git-completion.tcsh $1
cp -f          $SCRIPT_DIR/.git-prompt.csh $1
cp -f          $SCRIPT_DIR/.git-prompt.sh $1
cp -f --backup $SCRIPT_DIR/.gitconfig $1
cp -f          $SCRIPT_DIR/.rg-completion.bash $1
cp -f          $SCRIPT_DIR/.set_base16.sh $1
cp -f --backup $SCRIPT_DIR/.tmux.conf $1
cp -f          $SCRIPT_DIR/.update_display.sh $1

# Restore origin git name and email
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Generate tmux-256color
/usr/bin/tic -xe tmux-256color $SCRIPT_DIR/terminfo.src

echo "====================================================="
echo "Installation completed"
echo "Reopen terminal and change shell color if you needed (base16_<Tab>)"
printf "
For WSL user, you should do following steps in first installation:
  1. Open Windows Terminal Settings
  2. Click your distro profile (Ex: Ubuntu-20.04)
  3. Change Starting directory to: \\\\\\\\wsl$\\{distro_name}\\home\\{user_name}
     Ex: \\\\\\\\wsl\$\\\\Ubuntu-20.04\\home\\henry
     You can check the distro name by going to \\\\\\\\wsl\$ in Windows Explorer
  4. Install fonts in \\\\\\\\wsl\$\\{distro_name}\\home\\{user_name}\\.fonts
     You may not directly install them in the folder. Simply copy them to other folder in Windows System.
     Or you can install one of patched fonts in https://github.com/ryanoasis/nerd-fonts
     There are different versions of one font style. Choose the one w/ Windows Compatible and w/o Mono.
     For following example, choose c version.
     a. Hack Regular Nerd Font Complete Mono Windows Compatible
     b. Hack Regular Nerd Font Complete Mono
     c. Hack Regular Nerd Font Complete Windows Compatible
     d. Hack Regular Nerd Font Complete
  5. In Apperance tab, change Font to \"Hack NF\"
     If you install other fonts, open Fonts in Windows 10 Settings.
     Search the font and find the font family's name (text colored as blue)
     Change other apperance settings if you want
  6. Click \"Open JSON file\"
     a. Change \"command\" at the next line of \"ctrl+c\" to \"unbound\"
        You don't want Linux SIGINT key to be occupied by Windows copy key
     b. Change \"ctrl+v\" at the next line of \"paste\" to \"shift+insert\"
        You don't want block selection key of Vim to be occupied by Windows paste key
  7. Install VcXsrv in Windows System: https://sourceforge.net/projects/vcxsrv/
  8. Open XLaunch, use default settings in \"Select display settings\" and \"Select how to start clients\"
     Add -ac in \"Additional parameters for VcXsrv\" of \"Extra settings\"
     Save configuration to %%APPDATA%%\\Microsoft\\Windows\\Start Menu\\Programs\\Startup
     This will help you to sync system clipboard with WSL and provides X windows ability
"
printf "
For VM/SSH user, you should do following steps in first installation:
  1. Use gnome-terminal or other VTE terminal as primary terminal
  2. Open gnome-terminal, change fonts to \"Hack NF\" or other fonts from Nerd Font
"
