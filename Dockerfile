FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
    ;

# 网页终端 webssh (纯 python, pip 强制安装到 /usr/local/bin)
RUN set -xe; \
    apt-get -yqq install --no-install-recommends python3-pip; \
    pip3 install --break-system-packages --no-cache-dir webssh==1.6.2 2>&1 | tail -5; \
    ls -la /usr/local/bin/wssh 2>&1 || ls -la $(python3 -m site --user-base)/bin/wssh 2>&1 || true

RUN echo "root:unikraft" | chpasswd
RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config

# ttyd 启动脚本 (网页终端, 密码 unikraft)
COPY ./ttyd.sh /usr/bin/ttyd.sh
RUN chmod +x /usr/bin/ttyd.sh

ENV LANG=C.UTF-8

CMD ["/usr/bin/wrapper.sh"]
