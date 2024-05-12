# Dockerfile

FROM centos:7

# Install necessary packages
RUN yum update -y && \
    yum install -y https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm epel-release && \
    yum groupinstall -y 'Development Tools' && \
    yum install -y gzip xz unzip git curl rsync
