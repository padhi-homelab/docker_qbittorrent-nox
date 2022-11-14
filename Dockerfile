FROM alpine:3.16.3 AS qbittorrent-build

ARG QBITTORRENT_VERSION=4.4.5
ARG QBITTORRENT_SHA_512=a2b6ecd9a6f087a7ecaad2774d395ee4b2164cb8540b9f32574640f485fa3fc8688046d30e0179863a0aff1524d69b83c00bc232c7feb9ad737c79a05734ad95

ARG LIBTORRENT_VERSION=2.0.6
ARG LIBTORRENT_SHA_512=4a5d710706040ef6193967dbb13998cb0ddebe7e95c3bf8aec0812876027c68c32b001fd3f07cd4ff1b819660a8d46ae8c7077e72caf92572288a51cdec7daea

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
            openssl-dev \
            python3-dev \
            qt6-qtbase-dev \
            qt6-qttools-dev \
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
          -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
          -DGUI=OFF \
          -DSTACKTRACE=OFF \
          -DQT6=ON \
 && cmake --build build \
 && cmake --install build


FROM alpine:3.16.3 AS ipfilter-build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter/sources \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:3.16.2_0.19.0_0.2


COPY --from=qbittorrent-build \
     /usr/local/lib/libtorrent-rasterbar.so.2.0 \
     /usr/local/lib/
COPY --from=qbittorrent-build \
     /usr/local/bin/qbittorrent-nox \
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
            qt6-qtbase \
            tzdata \
            zlib


EXPOSE 8080
VOLUME [ "/config", "/data", "/torrents/complete", "/torrents/incomplete" ]


CMD [ "qbittorrent" ]


HEALTHCHECK --start-period=10s --interval=30s --timeout=5s --retries=3 \
        CMD ["wget", "-qSO", "/dev/null",  "http://localhost:8080/"]
