#!/bin/sh

set -ex

chown root:root /run/sshd

export HOME=/root
export LANG=C.UTF-8
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH

if test ! -z "$PUBKEY"; then
    echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi

# 启动 SSH (保持运行, 即使 webssh 失败也不退)
/usr/sbin/sshd -D -h /etc/ssh/ssh_host_ecdsa_key -p 2222 &

# 启动 webssh 网页终端 (6080)
echo "starting webssh at $(date)" > /var/log/webssh.log
/usr/bin/ttyd.sh >>/var/log/webssh.log 2>&1 &

# 保持容器运行, 不退出
echo "wrapper done, staying alive" >> /var/log/webssh.log
wait
