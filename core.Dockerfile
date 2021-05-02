FROM padhihomelab/alpine-base:edge AS qbittorrent-build

ARG QBITTORRENT_VERSION=4.3.4.1
ARG QBITTORRENT_SHA_512=f1f2d6dd445b37b7397f38f965221d2f440e3aae208f19508d9b68c507f2461216bba7240f1ead21fa5ab4c08c437dc9f2b4030daca6c27a20ad0c4e66c6ecc0

ADD https://github.com/qbittorrent/qBittorrent/archive/release-${QBITTORRENT_VERSION}.tar.gz \
    /tmp/qbittorrent.tar.gz

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
 && cd /ipfilter/sources \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:edge


COPY --from=qbittorrent-build \
     /tmp/qbittorrent/src/qbittorrent-nox \
     /usr/bin
COPY --from=ipfilter-build \
     /ipfilter/sources/ipfilter.p2p /

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
            qt5-qtbase \
            zlib


EXPOSE 8080
VOLUME [ "/config", "/data", "/torrents/complete", "/torrents/incomplete" ]


CMD [ "qbittorrent" ]


HEALTHCHECK --start-period=10s --interval=30s --timeout=5s --retries=3 \
        CMD ["wget", "--tries", "5", "-qSO", "/dev/null",  "http://localhost:8080/"]
