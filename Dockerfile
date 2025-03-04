FROM ubuntu:22.04

RUN apt update && \
    apt install -y wget && \
    wget https://github.com/xmrig/xmrig/releases/download/v6.20.0/xmrig-6.20.0-linux-static-x64.tar.gz && \
    tar -zxvf xmrig-*.tar.gz && \
    cp xmrig-*/xmrig /usr/local/bin/

CMD ["xmrig", "-o", "$POOL", "-u", "$WALLET", "--donate-level=1"]
