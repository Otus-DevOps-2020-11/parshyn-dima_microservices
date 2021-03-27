FROM ubuntu:18.04

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="ubuntu-1804" \
    OS_NAME="linux"

# Install required system packages and dependencies
RUN apt-get update
RUN apt-get install -y ca-certificates curl gzip procps tar wget
RUN wget -nc -P /tmp/ https://github.com/prometheus/blackbox_exporter/releases/download/v0.18.0/blackbox_exporter-0.18.0.linux-amd64.tar.gz && \
    tar -C /opt -zxf /tmp/blackbox_exporter-0.18.0.linux-amd64.tar.gz && \
    rm -rf /tmp/blackbox_exporter-0.18.0.linux-amd64.tar.gz
RUN ln -sf /opt/blackbox_exporter-0.18.0.linux-amd64/blackbox_exporter /bin/blackbox_exporter

EXPOSE 9216

WORKDIR /opt/blackbox_exporter-0.18.0.linux-amd64/
USER 1001
ENTRYPOINT [ "blackbox_exporter" ]
