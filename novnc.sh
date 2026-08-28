#!/bin/sh
# noVNC 网页 VNC 启动脚本
set -e

export HOME=/root
export DISPLAY=:1
export LANG=C.UTF-8

mkdir -p "$HOME/.vnc"
echo "unikraft\nunikraft" | vncpasswd >/dev/null 2>&1 || true
chmod 600 "$HOME/.vnc/passwd" 2>/dev/null || true

# 启动 VNC (openbox 桌面)
tigervncserver "$DISPLAY" \
    -geometry 1280x720 \
    -depth 24 \
    -localhost \
    -SecurityTypes VncAuth \
    -passwd "$HOME/.vnc/passwd" \
    -xstartup /usr/bin/openbox-session \
    >/var/log/vnc.log 2>&1 &

sleep 2

# websockify: VNC(5901) -> 网页 noVNC(6080)
exec websockify --web /opt/novnc \
    0.0.0.0:6080 localhost:5901
