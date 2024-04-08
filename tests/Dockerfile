# Dockerfile

FROM python:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests -y tcsh

# Install pytest-workflow
RUN pip install pytest-workflow;
