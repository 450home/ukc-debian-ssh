#!/bin/sh

chown root:root /run/sshd

export HOME=/root

if test ! -z "$PUBKEY"; then
    echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi

# ttyd 网页终端 (6080, 用户 root 密码 unikraft)
/usr/bin/ttyd -p 6080 -c root:unikraft login > /var/log/ttyd.log 2>&1 &

exec /usr/sbin/sshd -D -h /etc/ssh/ssh_host_ecdsa_key -p 2222
