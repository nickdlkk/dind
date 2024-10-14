FROM debian:12

RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
 
 
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord


RUN apt-get update && apt-get install -y \
    bash \
    openssh-client \
    openssh-server \
    curl \
	wget \
	htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh \
	&& wget -O /usr/bin/docker-compose https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 \
	&& chmod +x /usr/bin/docker-compose 

COPY files /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/docker-entrypoint.sh"]
