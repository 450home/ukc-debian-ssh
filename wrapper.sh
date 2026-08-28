#!/bin/sh

chown root:root /run/sshd

export HOME=/root

if test ! -z "$PUBKEY"; then
    echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi

# webssh 后台 (网页终端 6080)
/usr/bin/ttyd.sh > /var/log/webssh.log 2>&1 &

exec /usr/sbin/sshd -D -h /etc/ssh/ssh_host_ecdsa_key -p 2222
