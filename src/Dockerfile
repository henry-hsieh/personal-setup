# Dockerfile

FROM ubuntu:latest

# Avoid interactive
ARG DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests -y musl musl-dev musl-tools libtinfo-dev gzip xz-utils make cmake git curl rsync ca-certificates pkg-config unzip file python2
