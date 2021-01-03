FROM alpine:3.12

WORKDIR /root
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TIMEZONE=Asia/Shanghai

COPY home /etc/skel/

RUN set -ex \
  ; apk update && apk upgrade \
  ; rm -rf /var/cache/apk/* \
  ; apk add --no-cache tzdata \
      sudo shadow pwgen xz unzip tree \
      curl wget socat tcpdump rsync jq \
      bash zsh neovim git \
      openssh-client openssh-server openssl \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  ; sed -i /etc/ssh/sshd_config \
        -e 's!.*\(AllowTcpForwarding\).*!\1 yes!' \
        -e 's!.*\(GatewayPorts\).*!\1 yes!' \
        -e 's!.*\(AuthorizedKeysFile\).*!\1 /etc/authorized_keys/%u!' \
        -e 's!.*\(ChallengeResponseAuthentication\).*yes!\1 no!' \
        -e 's!.*\(PasswordAuthentication\).*yes!\1 no!'

ENV just_version=0.8.3
ENV watchexec_version=1.14.1
ENV yq_version=4.2.1
ENV websocat_version=1.6.0

ARG just_url=https://github.com/casey/just/releases/download/v${just_version}/just-v${just_version}-x86_64-unknown-linux-musl.tar.gz
ARG watchexec_url=https://github.com/watchexec/watchexec/releases/download/${watchexec_version}/watchexec-${watchexec_version}-x86_64-unknown-linux-musl.tar.xz
ARG yq_url=https://github.com/mikefarah/yq/releases/download/v${yq_version}/yq_linux_amd64
ARG websocat_url=https://github.com/vi/websocat/releases/download/v${websocat_version}/websocat_amd64-linux-static

RUN set -ex \
  ; wget -q -O- ${just_url} \
    | tar zxf - -C /usr/local/bin just \
  ; wget -q -O- ${watchexec_url} \
    | tar Jxf - --strip-components=1 -C /usr/local/bin watchexec-${watchexec_version}-x86_64-unknown-linux-musl/watchexec \
  ; wget -q -O /usr/local/bin/yq ${yq_url} \
    ; chmod +x /usr/local/bin/yq \
  ; wget -q -O /usr/local/bin/websocat ${websocat_url} \
    ; chmod +x /usr/local/bin/websocat

ENV SSH_USERS=
ENV SSH_ENABLE_ROOT=

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
