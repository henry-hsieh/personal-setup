# Variables
src_dir := justfile_directory() / "src"
build_dir := justfile_directory() / "build"
output_dir := build_dir / "output"
cache_dir := ".cache" / "personal-setup"
host_cache_dir := env("HOME") / cache_dir
log_dir := build_dir / "logs"
test_src_dir := justfile_directory() / "tests"
test_dir := build_dir / "test"
test_home := test_dir / "home"
fast_fail := "1"
parallel := num_cpus()
retry := "3"
fast_fail_cmd := if fast_fail != "0" { "--fast-fail" } else { "" }
out := build_dir / "personal-setup.tar.gz"
cache_include_list := "opencode"
find_args := prepend("! -name ", cache_include_list)
static_exclude_list := ".npm .bash_history .tcsh_history .local/state tinty/current_scheme"
tar_static_excludes := prepend("--exclude=", static_exclude_list)

# Recipes
all: release

build: (build_home)

build_home:
    mkdir -p {{host_cache_dir}}/cargo/registry {{host_cache_dir}}/rustup/downloads
    docker run -t \
        --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined \
        -e TARGET_UID={{`id -u`}} \
        -e TARGET_GID={{`id -g`}} \
        -e TARGET_USER={{`id -un`}} \
        -e GITHUB_TOKEN={{env_var_or_default("GITHUB_TOKEN", "")}} \
        -v {{justfile_directory()}}:{{justfile_directory()}} \
        -v {{host_cache_dir}}:/home/{{`id -un`}}/{{cache_dir}} \
        -v {{host_cache_dir}}/cargo/registry:/home/{{`id -un`}}/.cargo/registry \
        -v {{host_cache_dir}}/rustup/downloads:/opt/rust/downloads \
        -w {{justfile_directory()}} \
        personal-setup \
        python {{justfile_directory()}}/src/build.py --out-dir build/output --parallel {{parallel}} --retry {{retry}} {{fast_fail_cmd}}

build_docker:
    docker build -q -t personal-setup {{src_dir}}

start_service:
    sudo service docker start

release: (build_home)
    mkdir -p {{build_dir}}/release
    cd {{output_dir}} && find .cache -mindepth 1 -maxdepth 1 {{find_args}} -printf "%p\n" > {{build_dir}}/exclude.list
    cd {{output_dir}} && tar -czf ../release/home.tar.gz \
        {{tar_static_excludes}} \
        --exclude-from={{build_dir}}/exclude.list \
        .
    rm -f {{build_dir}}/exclude.list
    cp src/install.sh {{build_dir}}/release/
    cd {{build_dir}} && tar -czf {{file_name(out)}} --transform='s/release/personal-setup/' release/

test:
    mkdir -p {{test_dir}} {{log_dir}}
    tar -axf {{out}} -C {{test_dir}}
    rm -rf {{test_home}}
    @echo "Installing environment..."
    {{test_dir}}/personal-setup/install.sh {{test_home}} > {{log_dir}}/install.log
    rm -rf {{test_dir}}/personal-setup
    cd {{test_home}} && HOME={{test_home}} bash -i -c "make -C {{test_src_dir}} LOG_DIR={{log_dir}} -j{{parallel}}"

clean:
    rm -rf {{build_dir}}
