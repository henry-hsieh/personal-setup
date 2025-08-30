# Dockerfile

FROM ubuntu:18.04

# Install necessary packages
RUN apt update && \
    apt install -y build-essential && \
    apt install -y gzip xz unzip git curl rsync

# Rustup and Cargo
ENV PATH=/tmp/.cargo/bin:$PATH
ENV CARGO_HOME=/tmp/.cargo
ENV RUSTUP_HOME=/tmp/.rustup
RUN curl -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y && \
    chmod 777 -R /tmp/.cargo /tmp/.rustup
