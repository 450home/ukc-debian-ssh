FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates locales \
    ;

# 轻量桌面 + noVNC 网页 VNC 全套
# 预先清空 ieee-data 的 postinst，避免 unikernel 下 configure 卡死
RUN set -xe; \
    apt-get -yqq install --no-install-recommends \
        tigervnc-standalone-server tigervnc-common \
        novnc websockify \
        openbox xterm \
        fonts-wqy-zenhei \
    ; \
    if [ -f /var/lib/dpkg/info/ieee-data.postinst ]; then \
        printf '#!/bin/sh\nexit 0\n' > /var/lib/dpkg/info/ieee-data.postinst; \
        chmod +x /var/lib/dpkg/info/ieee-data.postinst; \
    fi

RUN echo "root:unikraft" | chpasswd

RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config

# noVNC 启动脚本（VNC 1:1，网页 6080）
COPY ./novnc.sh /usr/bin/novnc.sh
RUN chmod +x /usr/bin/novnc.sh

# Openbox 简易环境 + 中文 locale
RUN sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=zh_CN.UTF-8

# 撑大 rootfs 到约 4GB（EROFS 对零块压缩，上传体积仍小）
RUN dd if=/dev/zero of=/rootfs_pad bs=1M count=3600 status=none || true
RUN rm -f /rootfs_pad

CMD ["/usr/bin/wrapper.sh"]
