# Variables
src_dir := justfile_directory() / "src"
build_dir := justfile_directory() / "build"
output_dir := build_dir / "output"
cache_dir := ".cache" / "personal-setup"
host_cache_dir := env("HOME") / cache_dir
log_dir := build_dir / "logs"
test_src_dir := justfile_directory() / "tests"
test_dir := build_dir / "test"
test_clean := ""
fast_fail := "1"
parallel := num_cpus()
retry := "3"
fast_fail_cmd := if fast_fail != "0" { "--fast-fail" } else { "" }
version := if shell("git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo true") == "true" {
    shell("git describe --tag --exact --exclude=\"nightly*\" 2> /dev/null || git rev-parse --short HEAD")
} else {
    "unknown"
}
out := build_dir / "personal-setup.tar.gz"
cache_include_list := "opencode"
find_args := prepend("! -name ", cache_include_list)
static_exclude_list := ".npm .bash_history .tcsh_history .local/state"
static_exclude_flags := prepend("--exclude=", static_exclude_list)

# Recipes
all: build release

build:
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

_generate_exclude:
    cd {{output_dir}} && find .cache -mindepth 1 -maxdepth 1 {{find_args}} -printf "%p\n" > {{build_dir}}/exclude.list
    cd {{output_dir}} && find .local/share/tinted-theming/tinty \( -type l -o -name ".tinty.lock" \) -printf "%p\n" >> {{build_dir}}/exclude.list

release: _generate_exclude
    cd {{build_dir}} && makeself.sh --xz --base64 --threads {{parallel}} --notemp --quiet --nox11 --sha256 \
        --tar-format posix --tar-extra "{{static_exclude_flags}} --exclude-from={{build_dir}}/exclude.list" \
        --target personal-setup-{{version}} --preextract "{{src_dir}}/pre-install.sh" \
        "{{output_dir}}" \
        "personal-setup.xz.sh" \
        "My personal Linux environment setup" \
        "{{src_dir}}/post-install.sh" \
        "$({{output_dir}}/.local/bin/tmux -V 2>/dev/null | awk '{print $2}')"

_test_setup:
    [ ! -z "{{test_clean}}" ] && rm -rf {{test_dir}} || true
    mkdir -p {{log_dir}}

_test_command:
    #!/usr/bin/env bash
    cd {{test_dir}} && HOME={{test_dir}} /bin/bash -i +m -e -c 'echo "Current Home: $HOME"; unalias -a; PARALLEL={{parallel}} {{test_src_dir}}/runner.sh; exit' 2>&1 | tee {{log_dir}}/result.log; exit ${PIPESTATUS[0]}

test_fast: _generate_exclude _test_setup && _test_command
    rsync -a {{static_exclude_flags}} --exclude-from={{build_dir}}/exclude.list {{output_dir}}/ {{test_dir}}

test: _test_setup && _test_command
    {{build_dir}}/personal-setup.xz.sh --target {{test_dir}} 2>&1 | tee {{log_dir}}/install.log

clean:
    rm -rf {{output_dir}}

clean_build:
    rm -rf {{build_dir}}
