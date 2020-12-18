FROM alpine:edge AS qbittorrent-build

ARG QBITTORRENT_VERSION=4.3.1
ARG QBITTORRENT_SHA_512=078efb45ec65d7e1342624e71d11fc93516925b08084907266cb6154623bc8b817ecae0ce99489c48b294f8c94f5f6c5ea3f24a9a6ad005fe3249e2a67d0b815

ADD https://github.com/qbittorrent/qBittorrent/archive/release-${QBITTORRENT_VERSION}.tar.gz \
    /tmp/qbittorrent.tar.gz
ADD https://github.com/qbittorrent/qBittorrent/archive/release-${QBITTORRENT_VERSION}.tar.gz \
    /tmp/qbittorrent.asc

# See: https://git.alpinelinux.org/aports/tree/testing/qbittorrent-nox/APKBUILD
RUN cd /tmp \
 && echo "${QBITTORRENT_SHA_512}  qbittorrent.tar.gz" > qbittorrent.tar.gz.sha512 \
 && sha512sum -c qbittorrent.tar.gz.sha512 \
 && tar xvzf qbittorrent.tar.gz \
 && mv qBittorrent-release-${QBITTORRENT_VERSION} qbittorrent \
 && cd qbittorrent \
 && apk add --no-cache --update \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
            boost-dev \
            build-base \
            libtorrent-rasterbar-dev \
            qt5-qtbase-dev \
            qt5-qttools-dev \
 && ./configure --disable-gui \
                --disable-qt-dbus \
 && make


FROM alpine:3.12 AS ipfilter-build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:edge


COPY --from=qbittorrent-build \
     /tmp/qbittorrent/src/qbittorrent-nox \
     /usr/bin
COPY --from=ipfilter-build \
     /ipfilter/ipfilter.p2p /

COPY qBittorrent.conf       /
COPY qbittorrent.sh         /usr/local/bin/qbittorrent
COPY setup-volume.sh        /etc/docker-entrypoint.d/


RUN chmod +x /usr/bin/qbittorrent-nox \
             /usr/local/bin/qbittorrent \
             /etc/docker-entrypoint.d/setup-volume.sh \
 && apk add --no-cache --update \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
            libcrypto1.1 \
            libgcc \
            libstdc++ \
            libtorrent-rasterbar \
            python3 \
            qt5-qtbase \
            tzdata \
            zlib


EXPOSE 8080
VOLUME [ "/config", "/data", "/torrents/complete", "/torrents/incomplete" ]


CMD [ "qbittorrent" ]


HEALTHCHECK --start-period=10s --interval=30s --timeout=5s --retries=3 \
        CMD ["wget", "--tries", "5", "-qSO", "/dev/null",  "http://localhost:8080/"]
