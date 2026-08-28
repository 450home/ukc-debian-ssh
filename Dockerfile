FROM debian:bookworm AS build

WORKDIR /src

RUN set -xe; \
    apt-get -yqq update; \
    apt-get -yqq install --no-install-recommends \
        openssh-server strace net-tools ca-certificates \
    ;

RUN echo "root:unikraft" | chpasswd

RUN mkdir -p /run/sshd

COPY ./sshd_config /etc/ssh/sshd_config

COPY ./wrapper.sh /usr/bin/wrapper.sh
RUN chmod +x /usr/bin/wrapper.sh

CMD ["/usr/bin/wrapper.sh"]
