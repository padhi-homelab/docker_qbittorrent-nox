FROM alpine:3.20.2 AS qbittorrent-build

ARG QBITTORRENT_VERSION=5.0.1
ARG QBITTORRENT_SHA_512=1f5c27c9b045da5c30aaf82933129c55ed2bb12cc6b1710f6e4acf9d28aee764fc3a460de14eee72da140ed9c1a4bc5a91491ecdc69dc9da1698688fb8484105

ARG LIBTORRENT_VERSION=2.0.10
ARG LIBTORRENT_SHA_512=a6406ccdd1d0c8d42543419a3b9edca880ab85e0849bfba29e3b1bd98f9630244aa3e88110cdf95e476792c9ea87a141fcb16a8c3b3e0c44c0076ebf6f9adbee

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
            boost-dev \
            build-base \
            cmake \
            ninja \
            openssl-dev>3 \
            python3-dev \
            qt6-qtbase-dev \
            qt6-qtsvg-dev \
            qt6-qttools-dev \
            samurai \
# See: https://www.rasterbar.com/products/libtorrent/building.html
 && cd /tmp/libtorrent \
 && cmake -B build -G Ninja \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_CXX_STANDARD=17 \
 && cmake --build build \
 && cmake --install build \
# See: https://git.alpinelinux.org/aports/tree/community/qbittorrent/APKBUILD
 && cd /tmp/qbittorrent \
 && cmake -B build -G Ninja \
          -DCMAKE_BUILD_TYPE=Release \
          -DGUI=OFF \
          -DWEBUI=ON \
          -DSTACKTRACE=OFF \
          -DTESTING=OFF \
 && cmake --build build \
 && cmake --install build


FROM alpine:3.20.2 AS ipfilter-build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:3.20.2_0.19.0_0.2


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
