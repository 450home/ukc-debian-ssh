#!/bin/sh

chown root:root /run/sshd

export HOME=/root

if test ! -z "$PUBKEY"; then
    echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi

exec /usr/sbin/sshd -D -h /etc/ssh/ssh_host_ecdsa_key -p 2222
