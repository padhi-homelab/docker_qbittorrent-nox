FROM alpine:3.21.3 AS qbittorrent-build

ARG QBITTORRENT_VERSION=5.1.0
ARG QBITTORRENT_SHA_512=7f693dc2069598e7b7b6f377107e82e6c74d8415c9d5f4feea07a8f71df99d68d7c6876f4d1d917239dcb7ca8b6d6bc195ccd2fa7d9afb91047f6105631000bc

ARG LIBTORRENT_VERSION=2.0.11
ARG LIBTORRENT_SHA_512=756fb24c44b5dcf22d0bbc06a812abc28be7388a409e577c71fb02b1ca3005040947244c0ae83bd3388264dd518119736b869397fedd7bdbcd60699b04a19969

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
            qt6-qtbase-dev qt6-qtsvg-dev qt6-qttools-dev \
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


FROM alpine:3.21.3 AS ipfilter-build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:3.21.3_0.19.0_0.2


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
