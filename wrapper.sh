#!/bin/sh

set -x

chown root:root /run/sshd

export HOME=/root
export LANG=C.UTF-8
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH

if test ! -z "$PUBKEY"; then
    echo "$PUBKEY" >> /root/.ssh/authorized_keys
fi

# webssh 后台 (网页终端 6080)
echo "starting webssh at $(date)" > /var/log/webssh.log
/usr/bin/ttyd.sh >>/var/log/webssh.log 2>&1 &

# SSH 前台 (完全照抄旧 debian-ssh 实例, 依赖平台注入 host key)
exec /usr/sbin/sshd -D -h /etc/ssh/ssh_host_ecdsa_key -p 2222
