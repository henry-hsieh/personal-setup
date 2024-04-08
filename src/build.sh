#!/bin/bash

# Version control
NVIM_VERSION=v0.9.4
BAT_VERSION=v0.24.0
FD_VERSION=v9.0.0
FZF_VERSION=0.44.1
VERIBLE_VERSION=v0.0-3471-g9cb45092
NODE_VERSION=v20.9.0
JDK_VERSION=22
RG_VERSION=14.0.3
TREE_SITTER_VERSION=v0.22.2
TMUX_VERSION=3.3a
NCURSES_VERSION=6.4
LIBEVENT_VERSION=2.1.12-stable
UTF8PROC_VERSION=2.6.1

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
mkdir -p $OUT_DIR
rsync -av $SETTINGS_DIR $OUT_DIR
rsync -av ${ROOT_DIR}/src/install.sh $TAR_DIR

# base16-shell
print_process_item "Clone base16-shell" 1
download_git_repo https://github.com/chriskempson/base16-shell.git $OUT_DIR/.config/base16-shell

# git
print_process_item "Download git-completion" 1
download_exe https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash $OUT_DIR/.local/share/bash-completion/completions/git
download_exe https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh $OUT_DIR/.local/share/scripts/git-prompt.sh

# nvim
print_process_item "Download nvim" 1
download_file https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz $BUILD_DIR/nvim-linux64.tar.gz
tar -axvf $BUILD_DIR/nvim-linux64.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/nvim-linux64
rsync -av bin $OUT_DIR/.local/
rsync -av lib $OUT_DIR/.local/
rsync -av man $OUT_DIR/.local/
rsync -av share $OUT_DIR/.local/
popd

# bat
print_process_item "Download bat" 1
download_file https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axvf $BUILD_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/bat-${BAT_VERSION}-x86_64-unknown-linux-musl
rsync -av bat $OUT_DIR/.local/bin/
rsync -av bat.1 $OUT_DIR/.local/man/man1/
cp -f autocomplete/bat.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# fd
print_process_item "Download fd" 1
download_file https://github.com/sharkdp/fd/releases/download/$FD_VERSION/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axvf $BUILD_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/fd-${FD_VERSION}-x86_64-unknown-linux-musl
rsync -av fd $OUT_DIR/.local/bin/
rsync -av fd.1 $OUT_DIR/.local/man/man1/
cp -f autocomplete/fd.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# fzf
print_process_item "Download fzf" 1
download_file https://github.com/junegunn/fzf/releases/download/$FZF_VERSION/fzf-${FZF_VERSION}-linux_amd64.tar.gz $BUILD_DIR/fzf-${FZF_VERSION}-linux_amd64.tar.gz
tar -axvf $BUILD_DIR/fzf-${FZF_VERSION}-linux_amd64.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/
rsync -av fzf $OUT_DIR/.local/bin/
popd
download_file https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1 $OUT_DIR/.local/man/man1/fzf.1
download_file https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf-tmux.1 $OUT_DIR/.local/man/man1/fzf-tmux.1
download_exe https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash $OUT_DIR/.local/share/scripts/fzf-completion.bash
download_exe https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash $OUT_DIR/.local/share/scripts/fzf-key-bindings.bash
download_exe https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux $OUT_DIR/.local/bin/fzf-tmux

# fzf-tab-completion
print_process_item "Download fzf-tab-completion" 1
download_exe https://raw.githubusercontent.com/lincheney/fzf-tab-completion/master/bash/fzf-bash-completion.sh $OUT_DIR/.local/share/scripts/fzf-bash-completion.sh

# node (use unofficial builds)
print_process_item "Download node" 1
download_file https://unofficial-builds.nodejs.org/download/release/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz $BUILD_DIR/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz
tar -axvf $BUILD_DIR/node-${NODE_VERSION}-linux-x64-glibc-217.tar.xz -C $BUILD_DIR
pushd $BUILD_DIR/node-${NODE_VERSION}-linux-x64-glibc-217
rsync -av bin $OUT_DIR/.local/
rsync -av include $OUT_DIR/.local/
rsync -av lib $OUT_DIR/.local/
rsync -av share $OUT_DIR/.local/
popd

# jdk
print_process_item "Download jdk" 1
JDK_URL=$(get_openjdk_download_url $JDK_VERSION linux-x64)
download_file $JDK_URL $BUILD_DIR/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz
tar -axvf $BUILD_DIR/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR
mkdir -p $OUT_DIR/.local/lib/jvm/
rsync -av jdk-${JDK_VERSION} $OUT_DIR/.local/lib/jvm/
pushd $OUT_DIR/.local/lib
ln -s jvm/jdk-${JDK_VERSION} java
popd
popd

# ripgrep
print_process_item "Download ripgrep" 1
download_file https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz $BUILD_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
tar -axvf $BUILD_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz -C $BUILD_DIR
pushd $BUILD_DIR/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl
rsync -av rg $OUT_DIR/.local/bin/
rsync -av doc/rg.1 $OUT_DIR/.local/man/man1/
cp -f complete/rg.bash $OUT_DIR/.local/share/bash-completion/completions/
popd

# tree-sitter
download_file https://github.com/tree-sitter/tree-sitter/releases/download/${TREE_SITTER_VERSION}/tree-sitter-linux-x64.gz $BUILD_DIR/tree-sitter-${TREE_SITTER_VERSION}-linux-x64.gz
gzip -dc < $BUILD_DIR/tree-sitter-${TREE_SITTER_VERSION}-linux-x64.gz > $OUT_DIR/.local/bin/tree-sitter
chmod 755 $OUT_DIR/.local/bin/tree-sitter

# bd
print_process_item "Download bd" 1
download_exe https://raw.githubusercontent.com/vigneshwaranr/bd/master/bd $OUT_DIR/.local/bin/bd
download_exe https://raw.githubusercontent.com/vigneshwaranr/bd/master/bash_completion.d/bd $OUT_DIR/.local/share/bash-completion/completions/bd

# goto
print_process_item "Download goto" 1
download_exe https://raw.githubusercontent.com/iridakos/goto/master/goto.sh $OUT_DIR/.local/share/scripts/goto.sh

# tmux
print_process_item "Download tmux sources" 1
download_file https://github.com/libevent/libevent/releases/download/release-$LIBEVENT_VERSION/libevent-$LIBEVENT_VERSION.tar.gz $BUILD_DIR/tmux/libevent-$LIBEVENT_VERSION.tar.gz
tar -axvf $BUILD_DIR/tmux/libevent-$LIBEVENT_VERSION.tar.gz -C $BUILD_DIR/tmux
download_file https://invisible-mirror.net/archives/ncurses/ncurses-$NCURSES_VERSION.tar.gz $BUILD_DIR/tmux/ncurses-$NCURSES_VERSION.tar.gz
tar -axvf $BUILD_DIR/tmux/ncurses-$NCURSES_VERSION.tar.gz -C $BUILD_DIR/tmux
download_file https://github.com/JuliaLang/utf8proc/archive/v$UTF8PROC_VERSION.tar.gz $BUILD_DIR/tmux/utf8proc-$UTF8PROC_VERSION.tar.gz
tar -axvf $BUILD_DIR/tmux/utf8proc-$UTF8PROC_VERSION.tar.gz -C $BUILD_DIR/tmux
download_file https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz $BUILD_DIR/tmux/tmux-$TMUX_VERSION.tar.gz
tar -axvf $BUILD_DIR/tmux/tmux-$TMUX_VERSION.tar.gz -C $BUILD_DIR/tmux
pushd $BUILD_DIR/tmux
TMUX_BUILD_DEPENDENCIES=$BUILD_DIR/tmux/dependencies
TMUX_CFLAGS="-fPIC -I$TMUX_BUILD_DEPENDENCIES/include -I$TMUX_BUILD_DEPENDENCIES/include/ncurses"
TMUX_LDFLAGS="-L$TMUX_BUILD_DEPENDENCIES/lib"
TMUX_PKG_CONFIG_PATH=$TMUX_BUILD_DEPENDENCIES/lib/pkgconfig
TMUX_NCURSESW_PC_PATH=$(find $(pkg-config --variable pc_path pkg-config|tr ':' ' ') -name "ncursesw.pc" 2>/dev/null)
TMUX_NCURSES_PC_PATH=$(find $(pkg-config --variable pc_path pkg-config|tr ':' ' ') -name "ncurses.pc" 2>/dev/null)
TEMP_CC=${CC}
TEMP_CFLAGS=${CFLAGS}
TEMP_LDFLAGS=${LDFLAGS}
export CC=musl-gcc
export CFLAGS="$TMUX_CFLAGS"
export LDFLAGS="$TMUX_LDFLAGS"
## build libevent ##
print_process_item "Build libevent" 1
pushd libevent-$LIBEVENT_VERSION
./configure --prefix="$TMUX_BUILD_DEPENDENCIES" --disable-openssl --enable-shared=no --enable-static=yes --with-pic
make -j install
if [[ 0 -ne $? ]]; then
  echo "Build libevent failed"
  exit 1
fi
popd
## build ncurses ##
print_process_item "Build ncurses" 1
pushd ncurses-$NCURSES_VERSION
./configure --prefix="$TMUX_BUILD_DEPENDENCIES" --without-cxx --without-cxx-binding --with-termlib --enable-termcap \
--enable-ext-colors --enable-ext-mouse --enable-bsdpad --enable-opaque-curses \
--with-terminfo-dirs=/etc/terminfo:/usr/share/terminfo:/lib/terminfo \
--with-termpath=/etc/termcap:/usr/share/misc/termcap
make -j install
if [[ 0 -ne $? ]]; then
  echo "Build ncurses failed"
  exit 1
fi
popd
## build utf8proc ##
print_process_item "Build utf8proc" 1
mkdir -p utf8proc-$UTF8PROC_VERSION/build
pushd utf8proc-$UTF8PROC_VERSION/build
cmake .. -DCMAKE_INSTALL_PREFIX="$TMUX_BUILD_DEPENDENCIES" -DBUILD_SHARED_LIBS=OFF
cmake --build . --target install -j
if [[ 0 -ne $? ]]; then
  echo "Build utf8proc failed"
  exit 1
fi
popd
## build tmux ##
print_process_item "Build tmux" 1
pushd tmux-$TMUX_VERSION
if [[ "$TMUX_NCURSESW_PC_PATH" != "" ]]; then
  TMUX_NCURSES_CFLAGS="$(pkg-config --cflags $TMUX_NCURSESW_PC_PATH)"
  TMUX_NCURSES_LIBS="$(pkg-config --libs $TMUX_NCURSESW_PC_PATH)"
elif [[ "$TMUX_NCURSES_PC_PATH" != "" ]]; then
  TMUX_NCURSES_CFLAGS="$(pkg-config --cflags $TMUX_NCURSES_PC_PATH)"
  TMUX_NCURSES_LIBS="$(pkg-config --libs $TMUX_NCURSES_PC_PATH)"
else
  TMUX_NCURSES_CFLAGS=""
  TMUX_NCURSES_LIBS=""
fi
./configure --prefix="$OUT_DIR/.local/" \
--enable-static --enable-utf8proc \
PKG_CONFIG_PATH="$TMUX_PKG_CONFIG_PATH" \
LIBNCURSES_CFLAGS="$TMUX_NCURSES_CFLAGS" \
LIBNCURSES_LIBS="$TMUX_NCURSES_LIBS" \
LIBEVENT_CFLAGS="$(pkg-config --cflags $TMUX_BUILD_DEPENDENCIES/lib/pkgconfig/libevent.pc)" \
LIBEVENT_LIBS="$(pkg-config --libs $TMUX_BUILD_DEPENDENCIES/lib/pkgconfig/libevent.pc)"
make -j install
if [[ 0 -ne $? ]]; then
  echo "Build tmux failed"
  exit 1
fi
popd
## copy terminfo ##
print_process_item "Copy terminfo" 1
rsync -av ncurses-$NCURSES_VERSION/misc/terminfo.src $TAR_DIR
TEMP_CC=${CC}
TEMP_CFLAGS=${CFLAGS}
TEMP_LDFLAGS=${LDFLAGS}
export CC=${TEMP_CC}
export CFLAGS="$TEMP_CFLAGS"
export LDFLAGS="$TEMP_LDFLAGS"
popd

# tpm
print_process_item "Clone tpm" 1
download_git_repo https://github.com/tmux-plugins/tpm.git $OUT_DIR/.tmux/plugins/tpm
