FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates wget \
    ;

RUN echo "root:unikraft" | chpasswd

RUN mkdir -p /run/sshd

# ttyd 网页终端 (musl 静态二进制, 零依赖, unikernel 兼容)
RUN set -xe; \
    wget -qO /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 \
    || wget -qO /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64; \
    chmod +x /usr/bin/ttyd; \
    ldd /usr/bin/ttyd 2>&1 | head -1; \
    apt-get -yqq purge -y wget; \
    apt-get -yqq autoremove --purge -y

COPY ./sshd_config /etc/ssh/sshd_config

COPY ./wrapper.sh /usr/bin/wrapper.sh
RUN chmod +x /usr/bin/wrapper.sh

CMD ["/usr/bin/wrapper.sh"]
