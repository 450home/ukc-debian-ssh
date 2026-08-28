FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
    ;

# 网页终端 webssh (纯 python, pip 强制安装后清理 pip 节省空间)
RUN set -xe; \
    apt-get -yqq install --no-install-recommends python3-pip; \
    pip3 install --break-system-packages --no-cache-dir webssh==1.6.2 2>&1 | tail -3; \
    ls -la /usr/local/bin/wssh 2>&1 || true; \
    apt-get -yqq purge -y python3-pip; \
    apt-get -yqq autoremove --purge -y; \
    rm -rf /root/.cache/pip

RUN echo "root:unikraft" | chpasswd
RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config

# ttyd 启动脚本 (网页终端, 密码 unikraft)
COPY ./ttyd.sh /usr/bin/ttyd.sh
RUN chmod +x /usr/bin/ttyd.sh

ENV LANG=C.UTF-8

CMD ["/usr/bin/wrapper.sh"]
