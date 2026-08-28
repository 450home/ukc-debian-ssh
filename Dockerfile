FROM debian:bookworm AS build

WORKDIR /src

# 基础 SSH 工具（精简）
RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
    ;

# [临时测试] 不装 webssh
RUN echo "skip webssh for test"

RUN echo "root:unikraft" | chpasswd
RUN mkdir -p /run/sshd /etc/ssh

# 预生成 sshd host key (避免依赖平台注入)
RUN rm -f /etc/ssh/ssh_host_ecdsa_key && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N "" -q && ls -la /etc/ssh/ssh_host_ecdsa_key

COPY ./sshd_config /etc/ssh/sshd_config

# ttyd 启动脚本 (网页终端, 密码 unikraft)
COPY ./ttyd.sh /usr/bin/ttyd.sh
RUN chmod +x /usr/bin/ttyd.sh

ENV LANG=C.UTF-8

CMD ["/usr/bin/wrapper.sh"]
