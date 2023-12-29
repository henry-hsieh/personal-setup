#!/bin/bash

# Version control
NVIM_VERSION=v0.9.4
BAT_VERSION=v0.24.0
FD_VERSION=v9.0.0
FZF_VERSION=0.44.1
VERIBLE_VERSION=v0.0-3471-g9cb45092
NODE_VERSION=v20.9.0
RG_VERSION=14.0.3
TMUX_VERSION=3.3a

# Directory path
BUILD_DIR=$(dirname $(realpath $0))/build/
TEMP_DIR=$(dirname $(realpath $0))/temp/
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

# Copy settings
mkdir -p $BUILD_DIR
mkdir -p $TEMP_DIR
rsync -av $SETTINGS_DIR $BUILD_DIR

# base16-shell
if [ ! -d $BUILD_DIR/.config/base16-shell ]; then
  git clone https://github.com/chriskempson/base16-shell.git --depth 1 $BUILD_DIR/.config/base16-shell
else
  pushd $BUILD_DIR/.config/base16-shell
  git checkout master
  git pull --depth 1 origin master
  popd
fi

# nvim
curl -L https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz > $TEMP_DIR/nvim-linux64.tar.gz
tar -zxvf $TEMP_DIR/nvim-linux64.tar.gz -C $TEMP_DIR
pushd $TEMP_DIR/nvim-linux64
rsync -av bin $BUILD_DIR/.local/
rsync -av lib $BUILD_DIR/.local/
rsync -av man $BUILD_DIR/.local/
rsync -av share $BUILD_DIR/.local/
popd

# bat
curl -L https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz > $TEMP_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -zxvf $TEMP_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $TEMP_DIR
pushd $TEMP_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl
rsync -av bat $BUILD_DIR/.local/bin/
rsync -av bat.1 $BUILD_DIR/.local/man/man1/
cp -f autocomplete/bat.bash $BUILD_DIR/.bat-completion.bash
popd

# fd
curl -L https://github.com/sharkdp/fd/releases/download/$FD_VERSION/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz > $TEMP_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -zxvf $TEMP_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $TEMP_DIR
pushd $TEMP_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl
rsync -av fd $BUILD_DIR/.local/bin/
rsync -av fd.1 $BUILD_DIR/.local/man/man1/
cp -f autocomplete/fd.bash $BUILD_DIR/.fd-completion.bash
popd

# fzf
curl -L https://github.com/junegunn/fzf/releases/download/$FZF_VERSION/fzf-${FZF_VERSION}-linux_amd64.tar.gz > $TEMP_DIR/fzf-${FZF_VERSION}-linux_amd64.tar.gz
tar -zxvf $TEMP_DIR/fzf-${FZF_VERSION}-linux_amd64.tar.gz -C $TEMP_DIR
pushd $TEMP_DIR/
rsync -av fzf $BUILD_DIR/.local/bin/
popd
curl -L https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1 > $BUILD_DIR/.local/man/man1/fzf.1
curl -L https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf-tmux.1 > $BUILD_DIR/.local/man/man1/fzf-tmux.1
curl -L https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash > $BUILD_DIR/.fzf-completion.bash
curl -L https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash > $BUILD_DIR/.fzf-key-bindings.bash
curl -L https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux > $BUILD_DIR/.local/bin/

# verible
curl -L https://github.com/chipsalliance/verible/releases/download/$VERIBLE_VERSION/verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz > $TEMP_DIR/verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz
tar -zxvf $TEMP_DIR/verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz -C $TEMP_DIR
pushd $TEMP_DIR/verible-${VERIBLE_VERSION}
rsync -av bin $BUILD_DIR/.local/
popd

# node (use unofficial builds)
curl -L https://unofficial-builds.nodejs.org/download/release/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz > $TEMP_DIR/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz
tar -Jxvf $TEMP_DIR/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz -C $TEMP_DIR
pushd $TEMP_DIR/node-${NODE_VERSION}-linux-x64-glibc-217
rsync -av bin $BUILD_DIR/.local/
rsync -av include $BUILD_DIR/.local/
rsync -av lib $BUILD_DIR/.local/
rsync -av share $BUILD_DIR/.local/
popd

# ripgrep
curl -L https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz > $TEMP_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -zxvf $TEMP_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $TEMP_DIR
pushd $TEMP_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl
rsync -av rg $BUILD_DIR/.local/bin/
rsync -av doc/rg.1 $BUILD_DIR/.local/man/man1/
cp -f complete/rg.bash $BUILD_DIR/.rg-completion.bash
popd

# tmux
mkdir -p $TEMP_DIR/tmux/
curl -L https://raw.githubusercontent.com/henry-hsieh/tmux-build-musl/main/build-tmux.sh > $TEMP_DIR/tmux/build-tmux.sh
pushd $TEMP_DIR/tmux
chmod +x ./build-tmux.sh
if [[ -e prebuilt ]]; then
  rm -rf prebuilt; 
fi
TMUX_VERSION=$TMUX_VERSION NCURSES_VERSION=6.4 CC=musl-gcc ./build-tmux.sh
rsync -av prebuilt/tmux/bin $BUILD_DIR/.local/
rsync -av prebuilt/tmux/share $BUILD_DIR/.local/
popd

# tmux-plugins
if [ ! -d $BUILD_DIR/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm.git --depth 1 $BUILD_DIR/.tmux/plugins/tpm
else
  pushd $BUILD_DIR/.tmux/plugins/tpm
  git checkout master
  git pull --depth 1 origin master
  popd
fi
