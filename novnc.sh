#!/bin/sh
# noVNC 网页 VNC 启动脚本
# 启动 openbox 桌面 + tigervnc + websockify，网页访问 6080 端口即进桌面
set -e

export HOME=/root
export DISPLAY=:1
export LANG=zh_CN.UTF-8

# 初始化 VNC 密码（用固定密码 unikraft，方便登录）
mkdir -p "$HOME/.vnc"
echo "unikraft\nunikraft" | vncpasswd >/dev/null 2>&1 || true
chmod 600 "$HOME/.vnc/passwd" 2>/dev/null || true

# 启动 VNC server（openbox 桌面）
tigervncserver "$DISPLAY" \
    -geometry 1280x720 \
    -depth 24 \
    -localhost \
    -SecurityTypes VncAuth \
    -passwd "$HOME/.vnc/passwd" \
    -xstartup /usr/bin/openbox-session \
    >/var/log/vnc.log 2>&1 &

sleep 2

# websockify 把 VNC(5901) 转成网页 noVNC(6080)
exec websockify --web /usr/share/novnc \
    --cert /etc/ssl/certs/ssl-cert-snakeoil.pem \
    --key /etc/ssl/private/ssl-cert-snakeoil.key \
    0.0.0.0:6080 localhost:5901
