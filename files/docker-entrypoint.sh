#!/bin/bash

# 启用 bash 的错误检查
set -e

# 创建必要的目录
mkdir -p /var/log/supervisor /run/sshd

# 创建docker组和用户
groupadd -g 1000 docker || true
useradd -u 1000 -g docker -m -s /bin/bash "$USER" || true
echo "$USER:$PASSWORD" | chpasswd

# 生成SSH主机密钥
ssh-keygen -A

# 配置SSH
cat << EOF > /etc/ssh/sshd_config
Port 2022
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
UsePAM yes
PrintMotd no
# 添加以下行以增加日志详细程度
LogLevel DEBUG3
EOF

# 确保 /var/run/sshd 存在
mkdir -p /var/run/sshd

# 启动 SSH 服务
/usr/sbin/sshd -D -e &

ps aux | grep sshd

# 启动 supervisord
/usr/local/bin/supervisord -c /etc/supervisord.conf

