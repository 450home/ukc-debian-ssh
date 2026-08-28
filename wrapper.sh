#!/bin/sh

set -ex

chown root:root /run/sshd

export HOME=/root
export LANG=C.UTF-8
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH

if test ! -z "$PUBKEY"; then
    echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi

# 启动 SSH
/usr/sbin/sshd -D -h /etc/ssh/ssh_host_ecdsa_key -p 2222 &

# 启动 webssh 网页终端 (6080)
echo "starting webssh..." > /var/log/webssh.log
/usr/bin/ttyd.sh >>/var/log/webssh.log 2>&1 &

wait
