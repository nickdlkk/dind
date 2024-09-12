#!/bin/bash

mkdir -p /var/log/supervisor

echo Creating the user: $USER
echo Creating the PASSWORD: $PASSWORD

# 添加 docker 组和用户 dind
#addgroup -g 1000 docker
#adduser -u 1000 -D -G docker -s /bin/bash $USER
#echo "$USER:$PASSWORD" | chpasswd

echo Generating ssh host keys...
ssh-keygen -A 

mkdir -p /run/sshd
rm -f /var/run/docker.pid

# echo "$DEFAULT_PUBLIC_KEY" > /root/.ssh/authorized_keys
# # 修改权限
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# 修改 SSH 服务器配置文件允许证书登录
SSHD_CONFIG="/etc/ssh/sshd_config"

# 判断配置文件中是否已经包含允许证书登录的配置，如果没有则添加
if ! grep -q "^AuthorizedKeysFile .ssh/authorized_keys" "$SSHD_CONFIG"; then
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> "$SSHD_CONFIG"
fi
if ! grep -q "^PubkeyAuthentication yes" "$SSHD_CONFIG"; then
    echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
fi
if ! grep -q "^Port 2022" "$SSHD_CONFIG"; then
    echo "Port 2022" >> "$SSHD_CONFIG"
fi

echo Start the supervisord
/usr/local/bin/supervisord -c /etc/supervisord.conf

# addgroup docker && \
# adduser -D $USER -Gdocker -s /bin/bash > /dev/null 2>&1
# echo "$USER:$PASSWORD" | chpasswd > /dev/null 2>&1

# echo Generating ssh host keys...
# ssh-keygen -A > /dev/null 2>&1
# echo Start the supervisord
# /usr/local/bin/supervisord -c /etc/supervisord.conf
