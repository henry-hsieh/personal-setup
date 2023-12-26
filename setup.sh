#!/bin/bash

# Build docker
docker build -t personal-setup .

# Run docker
docker run --user $(id -u):$(id -g) -v $(pwd):/setup -w /setup personal-setup ./build.sh
docker run --user $(id -u):$(id -g) -v $(pwd):/setup -w /setup personal-setup sh -c 'HOME=/setup/build PATH=$PATH:/setup/build/.local/bin exec ./init.sh'

# Build tar
docker run --user $(id -u):$(id -g) -v $(pwd):/setup -w /setup personal-setup sh -c "tar -czvf personal-setup.tar.gz --transform='s,^build,personal-setup,' --exclude='.cache' --exclude='.npm' build"
