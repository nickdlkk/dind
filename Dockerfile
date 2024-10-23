FROM debian:12

RUN echo "deb http://mirrors.aliyun.com/debian/ bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

 
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord


RUN apt-get update && apt-get install -y \
    bash \
    openssh-client \
    openssh-server \
    curl \
  	wget \
  	htop \
    lsb-release\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

RUN curl -sSL https://linuxmirrors.cn/docker.sh -o /tmp/docker.sh && \
    bash /tmp/docker.sh --source mirrors.aliyun.com/docker-ce --source-registry d.990777.xyz --codename Bookworm --install-latested true && \
    rm /tmp/docker.sh

COPY files /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/docker-entrypoint.sh"]
