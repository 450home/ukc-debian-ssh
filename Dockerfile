FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
    ;

# 轻量桌面 + noVNC 网页 VNC（最小集）
# 不装 wqy 中文字体（省空间，中文会显示方块，可后续挂 volume 补）
RUN set -xe; \
    apt-get -yqq install --no-install-recommends \
        tigervnc-standalone-server \
        novnc websockify \
        openbox xterm \
    ; \
    if [ -f /var/lib/dpkg/info/ieee-data.postinst ]; then \
        printf '#!/bin/sh\nexit 0\n' > /var/lib/dpkg/info/ieee-data.postinst; \
        chmod +x /var/lib/dpkg/info/ieee-data.postinst; \
    fi

RUN echo "root:unikraft" | chpasswd

RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config

COPY ./novnc.sh /usr/bin/novnc.sh
RUN chmod +x /usr/bin/novnc.sh

# Openbox 英文环境（不加中文字体以控制镜像体积 < 1GB）
ENV LANG=C.UTF-8

CMD ["/usr/bin/wrapper.sh"]
