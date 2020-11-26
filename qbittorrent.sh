#!/bin/sh

set -e

if ! [ -d "$HOME/.config/qBittorrent" ]; then
    mkdir -p $HOME/.config
    ln -s /config $HOME/.config/qBittorrent
fi

qbittorrent-nox --webui-port=8080
