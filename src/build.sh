#!/usr/bin/env bash

# Version control
GIT_EXTRAS_VERSION=7.2.0
LAZYGIT_VERSION=0.41.0
NVIM_VERSION=v0.9.5
BAT_VERSION=v0.24.0
FD_VERSION=v9.0.0
FZF_VERSION=0.44.1
FZF_TAB_COMP_VERSION=ff97a3c398e0163194ac1dfea9a4fb7e039c10f1
NODE_VERSION=v20.9.0
JDK_VERSION=22
RG_VERSION=14.0.3
TREE_SITTER_VERSION=v0.22.2
TINTY_VERSION=v0.12.0
TMUX_VERSION=v3.4
HTOP_VERSION=v3.3.0
BD_VERSION=v1.03
GOTO_VERSION=v2.0.0
RUSTUP_VERSION=1.27.1
TPM_VERSION=v3.1.0

# Directory path
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
BUILD_DIR=${ROOT_DIR}/build/
TAR_DIR=${BUILD_DIR}/personal-setup/
OUT_DIR=${TAR_DIR}/build_home/
SETTINGS_DIR=$(dirname $(realpath $0))/settings/

# Command detection
if ! command -v git &> /dev/null
then
    echo "git could not be found"
    exit 1
fi
if ! command -v tar &> /dev/null
then
    echo "tar could not be found"
    exit 1
fi
if ! command -v gzip &> /dev/null
then
    echo "gzip could not be found"
    exit 1
fi
if ! command -v rsync &> /dev/null
then
    echo "rsync could not be found"
    exit 1
fi
if ! command -v curl &> /dev/null
then
    echo "curl could not be found"
    exit 1
fi
source ${ROOT_DIR}/src/utils.sh

# Copy settings
print_process_item "Copy settings"
mkdir -p $OUT_DIR
rsync -a $SETTINGS_DIR $OUT_DIR
rsync -a ${ROOT_DIR}/src/install.sh $TAR_DIR

# git-completion
print_process_item "Download git-completion"
download_exe https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash $OUT_DIR/.local/share/bash-completion/completions/git
download_exe https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh $OUT_DIR/.local/share/scripts/git-prompt.sh

# git-extras
print_process_item "Download git-extras"
download_git_repo https://github.com/tj/git-extras.git $BUILD_DIR/git-extras $GIT_EXTRAS_VERSION
pushd $BUILD_DIR/git-extras
make install DESTDIR=$OUT_DIR/ PREFIX=.local/ SYSCONFDIR=.local/share/
popd

# lazygit
print_process_item "Download lazygit"
download_file https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz $BUILD_DIR/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
mkdir -p $BUILD_DIR/lazygit
tar -axf $BUILD_DIR/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz -C $BUILD_DIR/lazygit
pushd $BUILD_DIR/lazygit
rsync -a lazygit $OUT_DIR/.local/bin/
popd

# nvim
print_process_item "Download nvim"
download_file https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz $BUILD_DIR/nvim-linux64.tar.gz
tar -axf $BUILD_DIR/nvim-linux64.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/nvim-linux64
rsync -a bin $OUT_DIR/.local/
rsync -a lib $OUT_DIR/.local/
rsync -a man $OUT_DIR/.local/
rsync -a share $OUT_DIR/.local/
popd

# bat
print_process_item "Download bat"
download_file https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axf $BUILD_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl
rsync -a bat $OUT_DIR/.local/bin/
rsync -a bat.1 $OUT_DIR/.local/man/man1/
cp -f autocomplete/bat.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# fd
print_process_item "Download fd"
download_file https://github.com/sharkdp/fd/releases/download/$FD_VERSION/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axf $BUILD_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl
rsync -a fd $OUT_DIR/.local/bin/
rsync -a fd.1 $OUT_DIR/.local/man/man1/
cp -f autocomplete/fd.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# fzf
print_process_item "Download fzf"
download_file https://github.com/junegunn/fzf/releases/download/$FZF_VERSION/fzf-${FZF_VERSION}-linux_amd64.tar.gz $BUILD_DIR/fzf-${FZF_VERSION}-linux_amd64.tar.gz
tar -axf $BUILD_DIR/fzf-${FZF_VERSION}-linux_amd64.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/
rsync -a fzf $OUT_DIR/.local/bin/
popd
download_file https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/man/man1/fzf.1 $OUT_DIR/.local/man/man1/fzf.1
download_file https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/man/man1/fzf-tmux.1 $OUT_DIR/.local/man/man1/fzf-tmux.1
download_exe https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/shell/completion.bash $OUT_DIR/.local/share/scripts/fzf-completion.bash
download_exe https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/shell/key-bindings.bash $OUT_DIR/.local/share/scripts/fzf-key-bindings.bash
download_exe https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/bin/fzf-tmux $OUT_DIR/.local/bin/fzf-tmux

# fzf-tab-completion
print_process_item "Download fzf-tab-completion"
download_exe https://raw.githubusercontent.com/lincheney/fzf-tab-completion/$FZF_TAB_COMP_VERSION/bash/fzf-bash-completion.sh $OUT_DIR/.local/share/scripts/fzf-bash-completion.sh

# node (use unofficial builds)
print_process_item "Download node"
download_file https://unofficial-builds.nodejs.org/download/release/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz $BUILD_DIR/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz
tar -axf $BUILD_DIR/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz -C $BUILD_DIR
pushd $BUILD_DIR/node-${NODE_VERSION}-linux-x64-glibc-217
rsync -a bin $OUT_DIR/.local/
rsync -a include $OUT_DIR/.local/
rsync -a lib $OUT_DIR/.local/
rsync -a share $OUT_DIR/.local/
popd

# jdk
print_process_item "Download jdk"
JDK_URL=$(get_openjdk_download_url $JDK_VERSION linux-x64)
download_file $JDK_URL $BUILD_DIR/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz
tar -axf $BUILD_DIR/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR
mkdir -p $OUT_DIR/.local/lib/jvm/
rsync -a jdk-${JDK_VERSION} $OUT_DIR/.local/lib/jvm/
pushd $OUT_DIR/.local/lib
ln -s jvm/jdk-${JDK_VERSION} java
popd
popd

# rustup
print_process_item "Download rustup"
download_exe https://static.rust-lang.org/rustup/archive/$RUSTUP_VERSION/x86_64-unknown-linux-gnu/rustup-init $BUILD_DIR/rustup-init-$RUSTUP_VERSION
CARGO_HOME=$OUT_DIR/.local/cargo RUSTUP_HOME=$OUT_DIR/.local/rustup $BUILD_DIR/rustup-init-$RUSTUP_VERSION -y
PATH=$OUT_DIR/.local/cargo/bin/:$PATH CARGO_HOME=$OUT_DIR/.local/cargo RUSTUP_HOME=$OUT_DIR/.local/rustup rustup default stable

# ripgrep
print_process_item "Download ripgrep"
download_file https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axf $BUILD_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl
rsync -a rg $OUT_DIR/.local/bin/
rsync -a doc/rg.1 $OUT_DIR/.local/man/man1/
cp -f complete/rg.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# tree-sitter
print_process_item "Download tree-sitter"
download_git_repo https://github.com/tree-sitter/tree-sitter.git $BUILD_DIR/tree-sitter $TREE_SITTER_VERSION
pushd $BUILD_DIR/tree-sitter
PATH=$OUT_DIR/.local/cargo/bin/:$PATH CARGO_HOME=$OUT_DIR/.local/cargo RUSTUP_HOME=$OUT_DIR/.local/rustup cargo build --release
rsync -a target/release/tree-sitter $OUT_DIR/.local/bin/
popd

# tinty
print_process_item "Download tinty"
download_file https://github.com/tinted-theming/tinty/releases/download/${TINTY_VERSION}/tinty--x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/tinty-${TINTY_VERSION}-x86_64-unknown-linux-musl.tar.gz
mkdir -p $BUILD_DIR/tinty
tar -axf $BUILD_DIR/tinty-${TINTY_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR/tinty
pushd $BUILD_DIR/tinty
rsync -a tinty $OUT_DIR/.local/bin/
rsync -a contrib/completion/tinty.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# htop
print_process_item "Download htop"
mkdir -p $BUILD_DIR/htop
download_exe https://github.com/henry-hsieh/htop.appimage/releases/download/${HTOP_VERSION}/Htop-x86_64.AppImage $BUILD_DIR/htop/Htop-x86_64.AppImage
pushd $BUILD_DIR/htop
mv Htop-x86_64.AppImage htop
rsync -a htop $OUT_DIR/.local/bin/
popd

# bd
print_process_item "Download bd"
download_exe https://raw.githubusercontent.com/vigneshwaranr/bd/$BD_VERSION/bd $OUT_DIR/.local/bin/bd
download_exe https://raw.githubusercontent.com/vigneshwaranr/bd/$BD_VERSION/bash_completion.d/bd $OUT_DIR/.local/share/bash-completion/completions/bd

# goto
print_process_item "Download goto"
download_exe https://raw.githubusercontent.com/iridakos/goto/$GOTO_VERSION/goto.sh $OUT_DIR/.local/share/scripts/goto.sh

# tmux
print_process_item "Download tmux"
mkdir -p $BUILD_DIR/tmux
download_exe https://github.com/henry-hsieh/tmux.appimage/releases/download/${TMUX_VERSION}/Tmux-x86_64.AppImage $BUILD_DIR/tmux/Tmux-x86_64.AppImage
pushd $BUILD_DIR/tmux
mv Tmux-x86_64.AppImage tmux
rsync -a tmux $OUT_DIR/.local/bin/
popd

# tpm
print_process_item "Clone tpm"
download_git_repo https://github.com/tmux-plugins/tpm.git $OUT_DIR/.tmux/plugins/tpm $TPM_VERSION
