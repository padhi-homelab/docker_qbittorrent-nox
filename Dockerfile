FROM alpine:3.15 AS qbittorrent-build

ARG QBITTORRENT_VERSION=4.4.0
ARG QBITTORRENT_SHA_512=7b1d4d45884d90bec14a28f01c9bdab0c9e2af496ade219393f4ccb14b9bb2901fc043407186da0efa1176f7fc9d1b1478864588e3869e363eb0eb35e5fe5c3f

ARG LIBTORRENT_VERSION=2.0.5
ARG LIBTORRENT_SHA_512=be5b812135dada957e565085b5bdda06827c8427f78a4468ef263e1a1e33d3a0bbba7ac27235f0d17ae6087d54311281e3b1975eef81cda514acc8329862dc04

ADD https://github.com/qbittorrent/qBittorrent/archive/release-${QBITTORRENT_VERSION}.tar.gz \
    /tmp/qbittorrent.tar.gz

ADD https://github.com/arvidn/libtorrent/releases/download/v${LIBTORRENT_VERSION}/libtorrent-rasterbar-${LIBTORRENT_VERSION}.tar.gz \
    /tmp/libtorrent.tar.gz

RUN cd /tmp \
 && echo "${LIBTORRENT_SHA_512}  libtorrent.tar.gz" > libtorrent.tar.gz.sha512 \
 && sha512sum -c libtorrent.tar.gz.sha512 \
 && tar xvzf libtorrent.tar.gz \
 && mv libtorrent-rasterbar-${LIBTORRENT_VERSION} libtorrent \
 && echo "${QBITTORRENT_SHA_512}  qbittorrent.tar.gz" > qbittorrent.tar.gz.sha512 \
 && sha512sum -c qbittorrent.tar.gz.sha512 \
 && tar xvzf qbittorrent.tar.gz \
 && mv qBittorrent-release-${QBITTORRENT_VERSION} qbittorrent \
 && apk add --no-cache --update \
            autoconf \
            automake \
            boost-dev \
            build-base \
            cmake \
            ninja \
            openssl-dev \
            python3-dev \
            qt5-qtbase-dev \
            qt5-qttools-dev \
# See: https://www.rasterbar.com/products/libtorrent/building.html
 && cd /tmp/libtorrent \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=14 -G Ninja .. \
 && ninja \
 && ninja install \
# See: https://git.alpinelinux.org/aports/tree/testing/qbittorrent-nox/APKBUILD
 && cd /tmp/qbittorrent \
 && ./configure --disable-gui \
                --disable-qt-dbus \
 && make


FROM alpine:3.15 AS ipfilter-build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter/sources \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:3.15.0_0.19.0_0.2


COPY --from=qbittorrent-build \
     /usr/local/lib/libtorrent-rasterbar.so.2.0 \
     /usr/local/lib/
COPY --from=qbittorrent-build \
     /tmp/qbittorrent/src/qbittorrent-nox \
     /usr/bin
COPY --from=ipfilter-build \
     /ipfilter/sources/ipfilter.p2p /

COPY qBittorrent.conf       /
COPY qbittorrent.sh         /usr/local/bin/qbittorrent

COPY entrypoint-scripts \
     /etc/docker-entrypoint.d/99-extra-scripts


RUN chmod +x /usr/bin/qbittorrent-nox \
             /usr/local/bin/qbittorrent \
             /etc/docker-entrypoint.d/99-extra-scripts/*.sh \
 && apk add --no-cache --update \
            libcrypto1.1 \
            libgcc \
            libstdc++ \
            python3 \
            qt5-qtbase \
            tzdata \
            zlib


EXPOSE 8080
VOLUME [ "/config", "/data", "/torrents/complete", "/torrents/incomplete" ]


CMD [ "qbittorrent" ]


HEALTHCHECK --start-period=10s --interval=30s --timeout=5s --retries=3 \
        CMD ["wget", "-qSO", "/dev/null",  "http://localhost:8080/"]
