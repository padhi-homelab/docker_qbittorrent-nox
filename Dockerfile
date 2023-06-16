FROM alpine:3.18.2 AS qbittorrent-build

ARG QBITTORRENT_VERSION=4.5.3
ARG QBITTORRENT_SHA_512=f175c71408504bffbd2c6b2967c2956d99e8e989b5326764d5085ac197c3aa6089f17cf663660ed70c704c011a1b535f09de8be3a031b4b65d3ba0f41beeaf03

ARG LIBTORRENT_VERSION=2.0.9
ARG LIBTORRENT_SHA_512=c252dbe1e2a246769017b8a622bb3418527e2bc2615115ac2bff9662afb53759bc7b2cbf6657438c515ba6de0140fc1c388b340c48b3dd9f7e6202ec0df1aec7

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


FROM alpine:3.18.2 AS ipfilter-build

RUN apk add --no-cache --update \
    bash \
    coreutils \
    git \
 && git clone https://github.com/fonic/ipfilter.git /ipfilter \
 && cd /ipfilter/sources \
 && ./ipfilter.sh


FROM padhihomelab/alpine-base:3.18.0_0.19.0_0.2


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
