#!/bin/bash

# 启用 bash 的错误检查
set -e

# 创建必要的目录
mkdir -p /var/log/supervisor /run/sshd /home/$USER/.ssh

# 检查是否需要生成新的 SSH 密钥
if [ ! -f "/home/$USER/.ssh/id_rsa" ]; then
    echo "No existing SSH key found. Generating new key pair..."
    # 生成 SSH 密钥对
    ssh-keygen -t rsa -b 4096 -f /home/$USER/.ssh/id_rsa -N ""
    
    # 将公钥添加到 authorized_keys
    cat /home/$USER/.ssh/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
else
    echo "Existing SSH key found. Skipping key generation."
fi

# 创建docker组和用户
groupadd -g 1000 docker || true
useradd -u 1000 -g docker -m -s /bin/bash "$USER" || true
echo "$USER:$PASSWORD" | chpasswd

# 设置正确的权限
chown -R $USER:docker /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/id_rsa
chmod 644 /home/$USER/.ssh/id_rsa.pub
chmod 600 /home/$USER/.ssh/authorized_keys
chown -R $USER:docker /home/$USER/.vscode-server
chown -R $USER:docker /home/$USER

# 将公钥添加到 authorized_keys
cat /home/$USER/.ssh/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
chmod 600 /home/$USER/.ssh/authorized_keys

# 生成SSH主机密钥（如果不存在）
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
    ssh-keygen -A
fi


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

# 打印公钥以便复制
echo "SSH public key for $USER:"
cat /home/$USER/.ssh/id_rsa.pub

# 启动 SSH 服务
/usr/sbin/sshd -D -e &

ps aux | grep sshd

# 启动 supervisord
/usr/local/bin/supervisord -c /etc/supervisord.conf

