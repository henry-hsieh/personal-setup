# Dockerfile

FROM ubuntu:18.04

# Install necessary packages
RUN apt update && \
    apt install -y --no-install-recommends \
        build-essential \
        software-properties-common \
        gzip \
        xz-utils \
        bsdmainutils \
        unzip \
        curl \
        fuse \
        llvm-dev \
        libclang-dev \
        clang \
        libatomic1 && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt update && \
    apt install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Rustup and Cargo
ENV RUSTUP_HOME="/opt/rust"
ENV CARGO_HOME="$RUSTUP_HOME"
ENV PATH="$RUSTUP_HOME/bin:$PATH"
RUN curl -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --no-modify-path -y && \
    chmod -R a+rX $RUSTUP_HOME
ENV CARGO_HOME=

# UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_PYTHON_INSTALL_DIR="/opt/uv-python"
ENV VIRTUAL_ENV="/opt/venv"
RUN uv venv $VIRTUAL_ENV --managed-python
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN uv pip install requests tenacity pyyaml

# Add entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
