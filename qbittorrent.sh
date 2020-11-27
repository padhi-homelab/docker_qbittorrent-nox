#!/bin/sh

set -e

if ! [ -d "$HOME/.config/qBittorrent" ]; then
    mkdir -p $HOME/.config
    ln -s /config $HOME/.config/qBittorrent
fi

if ! [ -d "$HOME/.local/share/data/qBittorrent" ]; then
    mkdir -p $HOME/.local/share/data
    ln -s /data $HOME/.local/share/data/qBittorrent
fi

qbittorrent-nox --webui-port=8080
