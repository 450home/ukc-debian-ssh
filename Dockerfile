FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
        python3 python3-pip wget \
    ;

# 轻量桌面: openbox + tigervnc (不装 apt 版 novnc/websockify，改用 pip 轻量装)
RUN set -xe; \
    apt-get -yqq install --no-install-recommends \
        tigervnc-standalone-server \
        openbox xterm \
    ; \
    if [ -f /var/lib/dpkg/info/ieee-data.postinst ]; then \
        printf '#!/bin/sh\nexit 0\n' > /var/lib/dpkg/info/ieee-data.postinst; \
        chmod +x /var/lib/dpkg/info/ieee-data.postinst; \
    fi

# 轻量 websockify (pip, 不拉 python3-oslo 重依赖)
RUN pip3 install --no-cache-dir websockify 2>&1 | tail -2 || \
    apt-get -yqq install --no-install-recommends websockify

# 下载 novnc 网页静态文件 (几 MB)
RUN set -xe; \
    wget -qO /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz || \
    wget -qO /tmp/novnc.tar.gz https://codeload.github.com/novnc/noVNC/tar.gz/refs/tags/v1.4.0 ; \
    mkdir -p /opt/novnc && tar -xzf /tmp/novnc.tar.gz -C /opt/novnc --strip-components=1 ; \
    rm -f /tmp/novnc.tar.gz ; \
    ls /opt/novnc/ | head

RUN echo "root:unikraft" | chpasswd
RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config
COPY ./novnc.sh /usr/bin/novnc.sh
RUN chmod +x /usr/bin/novnc.sh

ENV LANG=C.UTF-8

CMD ["/usr/bin/wrapper.sh"]
