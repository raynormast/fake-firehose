# syntax=docker/dockerfile:1
FROM ubuntu
RUN apt update && apt dist-upgrade -y
RUN apt install -y \
    jq \
    curl \
    nano \
    vim \
    dnsutils \
    wget

COPY ./scripts /scripts
WORKDIR /scripts
RUN chmod +x /scripts/*
ENTRYPOINT [ "/scripts/start-firehose.sh" ]