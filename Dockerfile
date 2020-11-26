FROM alpine:3.12 AS build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:edge


COPY --from=build \
     /ipfilter/ipfilter.p2p /

COPY qBittorrent.conf       /
COPY qbittorrent.sh         /usr/local/bin/qbittorrent
COPY setup-volume.sh        /etc/docker-entrypoint.d/


RUN chmod +x /usr/local/bin/qbittorrent \
             /etc/docker-entrypoint.d/setup-volume.sh \
 && apk add --no-cache --update \
            tzdata \
 && apk add --no-cache --update \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
            qbittorrent-nox


EXPOSE 8080
VOLUME [ "/config", "/data/complete", "/data/incomplete" ]


CMD [ "qbittorrent" ]


HEALTHCHECK --start-period=10s --interval=30s --timeout=5s --retries=3 \
        CMD ["wget", "--tries", "5", "-qSO", "/dev/null",  "http://localhost:8080/"]
