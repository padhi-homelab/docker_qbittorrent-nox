FROM alpine:3.23.4 AS qbittorrent-build

ARG QBITTORRENT_VERSION=5.2.1
ARG QBITTORRENT_SHA_512=495b57c964e90db0ff2cce13c8eeb6b6d6f4c0bfa45259b6b699dc0b9d823b3f39a69df32f7afa2aed2399949aef3eb92a5a47f652d31c467bf7ea24c5f192e6

ARG LIBTORRENT_VERSION=2.0.12
ARG LIBTORRENT_SHA_512=1bda7d45230c670bf3402873bf61fd4cd692daba16287fb5f213c3e5e3a9f34616061778944566343e4175ee71fc877fc370f7e0538231fcf8563dc959aabf93

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
            boost-dev build-base \
            cmake \
            ninja \
            openssl-dev>3 \
            python3-dev \
            qt6-qtbase-dev qt6-qtbase-private-dev qt6-qtsvg-dev qt6-qttools-dev \
            samurai \
# See: https://www.rasterbar.com/products/libtorrent/building.html
 && cd /tmp/libtorrent \
 && cmake -B build -G Ninja \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_CXX_STANDARD=17 \
 && cmake --build build \
 && cmake --install build \
# See: https://git.alpinelinux.org/aports/tree/community/qbittorrent/APKBUILD
 && export CFLAGS="$CFLAGS -DNDEBUG -O2 -flto=auto" \
 && export CXXFLAGS="$CXXFLAGS -DNDEBUG -O2 -flto=auto" \
 && cd /tmp/qbittorrent \
 && cmake -B build -G Ninja \
          -DCMAKE_BUILD_TYPE=Release \
          -DGUI=OFF \
          -DWEBUI=ON \
          -DSTACKTRACE=OFF \
          -DTESTING=OFF \
 && cmake --build build \
 && cmake --install build


FROM alpine:3.23.4 AS ipfilter-build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:3.23.4_0.19.0_0.3


COPY --from=qbittorrent-build \
     /usr/local/lib/libtorrent-rasterbar.so.2.0 \
     /usr/local/lib/
COPY --from=qbittorrent-build \
     /usr/local/bin/qbittorrent-nox \
     /usr/bin
COPY --from=ipfilter-build \
     /ipfilter/ipfilter.p2p /

COPY qBittorrent.conf       /
COPY qbittorrent.sh         /usr/local/bin/qbittorrent

COPY entrypoint-scripts \
     /etc/docker-entrypoint.d/99-extra-scripts


RUN chmod +x /usr/bin/qbittorrent-nox \
             /usr/local/bin/qbittorrent \
             /etc/docker-entrypoint.d/99-extra-scripts/*.sh \
 && apk add --no-cache --update \
            libcrypto3 \
            libgcc \
            libstdc++ \
            qt6-qtbase \
            zlib


EXPOSE 8080
VOLUME [ "/config", "/data", "/torrents/complete", "/torrents/incomplete" ]


CMD [ "qbittorrent" ]


HEALTHCHECK --start-period=10s --interval=30s --timeout=5s --retries=3 \
        CMD ["wget", "-qSO", "/dev/null",  "http://localhost:8080/"]
