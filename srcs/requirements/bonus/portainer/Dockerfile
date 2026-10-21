FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y curl ca-certificates tar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN ARCH=$(dpkg --print-architecture) && \
    curl -sL "https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-${ARCH}.tar.gz" -o portainer.tar.gz && \
    tar -xvf portainer.tar.gz && \
    rm portainer.tar.gz

EXPOSE 9000

WORKDIR /app/portainer

CMD ["./portainer"]
