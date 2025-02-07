#!/usr/bin/env bash

# Directory path
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
PKG_DIR=${ROOT_DIR}/packages
BUILD_DIR=${ROOT_DIR}/build/
TAR_DIR=${BUILD_DIR}/personal-setup/
OUT_DIR=${TAR_DIR}/build_home/
SETTINGS_DIR=$(dirname $(realpath $0))/settings/

# Version control
GIT_EXTRAS_VERSION=$(cat ${PKG_DIR}/git-extras/package.yaml | grep version: | sed 's/.\+:\s//g')
LAZYGIT_VERSION=$(cat ${PKG_DIR}/lazygit/package.yaml | grep version: | sed 's/.\+:\s//g')
NVIM_VERSION=$(cat ${PKG_DIR}/nvim/package.yaml | grep version: | sed 's/.\+:\s//g')
BAT_VERSION=$(cat ${PKG_DIR}/bat/package.yaml | grep version: | sed 's/.\+:\s//g')
FD_VERSION=$(cat ${PKG_DIR}/fd/package.yaml | grep version: | sed 's/.\+:\s//g')
FZF_VERSION=$(cat ${PKG_DIR}/fzf/package.yaml | grep version: | sed 's/.\+:\s//g')
FZF_TAB_COMP_VERSION=$(cat ${PKG_DIR}/fzf-tab-comp/package.yaml | grep version: | sed 's/.\+:\s//g')
NODE_VERSION=$(cat ${PKG_DIR}/node/package.yaml | grep version: | sed 's/.\+:\s//g')
JDK_VERSION=$(cat ${PKG_DIR}/jdk/package.yaml | grep version: | sed 's/.\+:\s//g')
RG_VERSION=$(cat ${PKG_DIR}/rg/package.yaml | grep version: | sed 's/.\+:\s//g')
TREE_SITTER_VERSION=$(cat ${PKG_DIR}/tree-sitter/package.yaml | grep version: | sed 's/.\+:\s//g')
TINTY_VERSION=$(cat ${PKG_DIR}/tinty/package.yaml | grep version: | sed 's/.\+:\s//g')
TMUX_VERSION=$(cat ${PKG_DIR}/tmux/package.yaml | grep version: | sed 's/.\+:\s//g')
HTOP_VERSION=$(cat ${PKG_DIR}/htop/package.yaml | grep version: | sed 's/.\+:\s//g')
BD_VERSION=$(cat ${PKG_DIR}/bd/package.yaml | grep version: | sed 's/.\+:\s//g')
GOTO_VERSION=$(cat ${PKG_DIR}/goto/package.yaml | grep version: | sed 's/.\+:\s//g')
RUSTUP_VERSION=$(cat ${PKG_DIR}/rustup/package.yaml | grep version: | sed 's/.\+:\s//g')
YQ_VERSION=$(cat ${PKG_DIR}/yq/package.yaml | grep version: | sed 's/.\+:\s//g')
TPM_VERSION=$(cat ${PKG_DIR}/tpm/package.yaml | grep version: | sed 's/.\+:\s//g')

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
download_file https://github.com/neovim/neovim-releases/releases/download/v$NVIM_VERSION/nvim-linux-x86_64.tar.gz  $BUILD_DIR/nvim-linux-x86_64.tar.gz
tar -axf $BUILD_DIR/nvim-linux-x86_64.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/nvim-linux-x86_64
rsync -a bin $OUT_DIR/.local/
rsync -a lib $OUT_DIR/.local/
rsync -a share $OUT_DIR/.local/
popd

# bat
print_process_item "Download bat"
download_file https://github.com/sharkdp/bat/releases/download/v$BAT_VERSION/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axf $BUILD_DIR/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl
rsync -a bat $OUT_DIR/.local/bin/
rsync -a bat.1 $OUT_DIR/.local/man/man1/
cp -f autocomplete/bat.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# fd
print_process_item "Download fd"
download_file https://github.com/sharkdp/fd/releases/download/v$FD_VERSION/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axf $BUILD_DIR/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/fd-v${FD_VERSION}-x86_64-unknown-linux-musl
rsync -a fd $OUT_DIR/.local/bin/
rsync -a fd.1 $OUT_DIR/.local/man/man1/
cp -f autocomplete/fd.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# fzf
print_process_item "Download fzf"
download_file https://github.com/junegunn/fzf/releases/download/$FZF_VERSION/fzf-${FZF_VERSION#v}-linux_amd64.tar.gz $BUILD_DIR/fzf-${FZF_VERSION#v}-linux_amd64.tar.gz
tar -axf $BUILD_DIR/fzf-${FZF_VERSION#v}-linux_amd64.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/
rsync -a fzf $OUT_DIR/.local/bin/
popd
download_file https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/man/man1/fzf.1 $OUT_DIR/.local/man/man1/fzf.1
download_exe https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/shell/completion.bash $OUT_DIR/.local/share/scripts/fzf-completion.bash
download_exe https://raw.githubusercontent.com/junegunn/fzf/$FZF_VERSION/shell/key-bindings.bash $OUT_DIR/.local/share/scripts/fzf-key-bindings.bash

# fzf-tab-completion
print_process_item "Download fzf-tab-completion"
download_exe https://raw.githubusercontent.com/lincheney/fzf-tab-completion/$FZF_TAB_COMP_VERSION/bash/fzf-bash-completion.sh $OUT_DIR/.local/share/scripts/fzf-bash-completion.sh

# node (use unofficial builds)
print_process_item "Download node"
download_file https://unofficial-builds.nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64-glibc-217.tar.xz $BUILD_DIR/node-v${NODE_VERSION}-linux-x64-glibc-217.tar.xz
tar -axf $BUILD_DIR/node-v${NODE_VERSION}-linux-x64-glibc-217.tar.xz -C $BUILD_DIR
pushd $BUILD_DIR/node-v${NODE_VERSION}-linux-x64-glibc-217
rsync -a bin $OUT_DIR/.local/
rsync -a include $OUT_DIR/.local/
rsync -a lib $OUT_DIR/.local/
rsync -a share $OUT_DIR/.local/
popd

# jdk
print_process_item "Download jdk"
download_file https://api.adoptium.net/v3/binary/version/jdk-$JDK_VERSION/linux/x64/jdk/hotspot/normal/adoptium $BUILD_DIR/jdk_x64_linux-${JDK_VERSION}.tar.gz
tar -axf $BUILD_DIR/jdk_x64_linux-${JDK_VERSION}.tar.gz -C $BUILD_DIR
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
download_git_repo https://github.com/tree-sitter/tree-sitter.git $BUILD_DIR/tree-sitter v$TREE_SITTER_VERSION
pushd $BUILD_DIR/tree-sitter
PATH=$OUT_DIR/.local/cargo/bin/:$PATH CARGO_HOME=$OUT_DIR/.local/cargo RUSTUP_HOME=$OUT_DIR/.local/rustup CFLAGS="-O3 -D_BSD_SOURCE" cargo build --release
rsync -a target/release/tree-sitter $OUT_DIR/.local/bin/
popd

# tinty
print_process_item "Download tinty"
download_file https://github.com/tinted-theming/tinty/releases/download/v${TINTY_VERSION}/tinty-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/tinty-v${TINTY_VERSION}-x86_64-unknown-linux-musl.tar.gz
mkdir -p $BUILD_DIR/tinty
tar -axf $BUILD_DIR/tinty-v${TINTY_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR/tinty
pushd $BUILD_DIR/tinty
rsync -a tinty $OUT_DIR/.local/bin/
download_exe https://raw.githubusercontent.com/tinted-theming/tinty/v${TINTY_VERSION}/contrib/completion/tinty.bash $OUT_DIR/.local/share/bash-completion/completions/tinty.bash
popd

# htop
print_process_item "Download htop"
mkdir -p $BUILD_DIR/htop
download_exe https://github.com/henry-hsieh/htop.appimage/releases/download/v${HTOP_VERSION}/Htop-x86_64.AppImage $BUILD_DIR/htop/Htop-x86_64.AppImage
download_file https://github.com/henry-hsieh/htop.appimage/releases/download/v${HTOP_VERSION}/htop.1 $OUT_DIR/.local/man/man1/htop.1
pushd $BUILD_DIR/htop
mv Htop-x86_64.AppImage htop
rsync -a htop $OUT_DIR/.local/bin/
popd

# bd
print_process_item "Download bd"
download_exe https://raw.githubusercontent.com/vigneshwaranr/bd/v$BD_VERSION/bd $OUT_DIR/.local/bin/bd
download_exe https://raw.githubusercontent.com/vigneshwaranr/bd/v$BD_VERSION/bash_completion.d/bd $OUT_DIR/.local/share/bash-completion/completions/bd

# goto
print_process_item "Download goto"
download_exe https://raw.githubusercontent.com/iridakos/goto/v$GOTO_VERSION/goto.sh $OUT_DIR/.local/share/scripts/goto.sh

# tmux
print_process_item "Download tmux"
mkdir -p $BUILD_DIR/tmux
download_exe https://github.com/henry-hsieh/tmux.appimage/releases/download/v${TMUX_VERSION}/Tmux-x86_64.AppImage $BUILD_DIR/tmux/Tmux-x86_64.AppImage
download_file https://github.com/henry-hsieh/tmux.appimage/releases/download/v${TMUX_VERSION}/tmux.1 $OUT_DIR/.local/man/man1/tmux.1
pushd $BUILD_DIR/tmux
mv Tmux-x86_64.AppImage tmux
rsync -a tmux $OUT_DIR/.local/bin/
popd

# yq
print_process_item "Download yq"
download_file https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64.tar.gz $BUILD_DIR/yq_linux_amd64.tar.gz
mkdir -p $BUILD_DIR/yq
tar -axf $BUILD_DIR/yq_linux_amd64.tar.gz -C $BUILD_DIR/yq
pushd $BUILD_DIR/yq
mv yq_linux_amd64 yq
rsync -a yq $OUT_DIR/.local/bin/
rsync -a yq.1 $OUT_DIR/.local/man/man1/
./yq shell-completion bash > $OUT_DIR/.local/share/bash-completion/completions/yq.bash
popd

# tpm
print_process_item "Clone tpm"
download_git_repo https://github.com/tmux-plugins/tpm.git $OUT_DIR/.config/tmux/plugins/tpm v$TPM_VERSION
