# Dockerfile

FROM ubuntu:18.04

# Install necessary packages
RUN apt update && \
    apt install -y build-essential software-properties-common && \
    apt install -y sudo gzip xz-utils bsdmainutils unzip git curl rsync fuse && \
    apt install -y llvm-dev libclang-dev clang && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt update && \
    apt install -y python3.8

# Rustup and Cargo
ENV PATH=/tmp/.cargo/bin:$PATH
ENV CARGO_HOME=/tmp/.cargo
ENV RUSTUP_HOME=/tmp/.rustup
RUN curl -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --no-modify-path -y && \
    chmod 777 -R /tmp/.cargo /tmp/.rustup

# Add entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
