#!/bin/bash

# 启用 bash 的错误检查
set -e

# 创建必要的目录
mkdir -p /var/log/supervisor /run/sshd /home/$USER/.ssh

# 备份和清理 .ssh 目录
if [ -d "/home/$USER/.ssh" ] && [ "$(ls -A /home/$USER/.ssh)" ]; then
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="/home/$USER/ssh_backup_$timestamp.tar.gz"
    tar -czf $backup_file -C /home/$USER .ssh
    echo "Existing SSH files backed up to $backup_file"
    rm -rf /home/$USER/.ssh/*
    echo "Cleaned .ssh directory"
    mv $backup_file /home/$USER/.ssh
fi

# 创建docker组和用户
groupadd -g 1000 docker || true
useradd -u 1000 -g docker -m -s /bin/bash "$USER" || true
echo "$USER:$PASSWORD" | chpasswd

# 生成 SSH 密钥对
ssh-keygen -t rsa -b 4096 -f /home/$USER/.ssh/id_rsa -N ""

# 设置正确的权限
chown -R $USER:docker /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/id_rsa
chmod 644 /home/$USER/.ssh/id_rsa.pub

# 将公钥添加到 authorized_keys
cat /home/$USER/.ssh/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
chmod 600 /home/$USER/.ssh/authorized_keys

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

