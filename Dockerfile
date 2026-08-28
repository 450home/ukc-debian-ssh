FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简，不带 pip/wget 重依赖）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
        python3 \
    ;

# 超精简: 只装 tigervnc + xterm (无窗口管理器, 无 novnc 静态文件)
RUN set -xe; \
    apt-get -yqq install --no-install-recommends \
        tigervnc-standalone-server \
        xterm \
    ; \
    if [ -f /var/lib/dpkg/info/ieee-data.postinst ]; then \
        printf '#!/bin/sh\nexit 0\n' > /var/lib/dpkg/info/ieee-data.postinst; \
        chmod +x /var/lib/dpkg/info/ieee-data.postinst; \
    fi

# novnc 网页静态文件 (只下载核心 vnc.html + 资源, 不拉 node/git 依赖)
RUN set -xe; \
    apt-get -yqq install --no-install-recommends wget; \
    wget -qO /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz; \
    mkdir -p /opt/novnc && tar -xzf /tmp/novnc.tar.gz -C /opt/novnc --strip-components=1; \
    rm -f /tmp/novnc.tar.gz; \
    apt-get -yqq purge -y wget; \
    apt-get -yqq autoremove --purge -y

# 自写纯标准库 websockify (替代 apt websockify 重依赖)
COPY ./pyws.py /usr/bin/pyws.py
RUN chmod +x /usr/bin/pyws.py

RUN echo "root:unikraft" | chpasswd
RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config
COPY ./novnc.sh /usr/bin/novnc.sh
RUN chmod +x /usr/bin/novnc.sh

ENV LANG=C.UTF-8

CMD ["/usr/bin/wrapper.sh"]
