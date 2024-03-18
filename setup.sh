#!/bin/bash

# Build docker
docker build -t personal-setup .

# Run docker
docker run --user $(id -u):$(id -g) -v $(pwd):/setup -w /setup personal-setup ./build.sh
docker run --user $(id -u):$(id -g) -v $(pwd):/setup -w /setup personal-setup sh -c 'HOME=/setup/build PATH=$PATH:/setup/build/.local/bin exec ./init.sh'

# Change permission
find build/ -type d -exec chmod g+rx {} \;
find build/ -type f -exec chmod g+r {} \;
find build/ -type f -perm /100 -exec chmod g+x {} \;

# Build tar
tar -czvf personal-setup.tar.gz --transform='s,^build,personal-setup,' --exclude='.cache' --exclude='.npm' build
