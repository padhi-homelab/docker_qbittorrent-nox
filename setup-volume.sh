#!/bin/sh

if ! [ -f "/config/qBittorrent.conf" ]; then
    cp /qBittorrent.conf /config/qBittorrent.conf
fi

if ! [ -f "/config/ipfilter.p2p" ]; then
    cp /ipfilter.p2p /config/ipfilter.p2p
fi

if [ -z "${ENTRYPOINT_RUN_AS_ROOT:-}" ]; then
    chown -R $DOCKER_USER:$DOCKER_GROUP /config /data /torrents
fi
