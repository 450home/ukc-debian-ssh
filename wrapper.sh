#!/bin/sh

set -ex

chown root:root /run/sshd

export HOME=/root
export LANG=C.UTF-8

if test ! -z "$PUBKEY"; then
    echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi

# 启动 SSH
/usr/sbin/sshd -D -h /etc/ssh/ssh_host_ecdsa_key -p 2222 &

# 启动 ttyd 网页终端 (6080)
/usr/bin/ttyd.sh &

wait
