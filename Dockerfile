FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
    ;

# 下载 ttyd 静态二进制 (官方 release, musl 静态链接, ~3MB, 零依赖)
RUN set -xe; \
    apt-get -yqq install --no-install-recommends wget ca-certificates; \
    wget -qO /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 \
    || wget -qO /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64; \
    chmod +x /usr/bin/ttyd; \
    apt-get -yqq purge -y wget; \
    apt-get -yqq autoremove --purge -y

RUN echo "root:unikraft" | chpasswd
RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config

# ttyd 启动脚本 (网页终端, 密码 unikraft)
COPY ./ttyd.sh /usr/bin/ttyd.sh
RUN chmod +x /usr/bin/ttyd.sh

ENV LANG=C.UTF-8

CMD ["/usr/bin/wrapper.sh"]
