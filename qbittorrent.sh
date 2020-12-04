#!/bin/sh

set -e

if ! [ -d "$HOME/.config/qBittorrent" ]; then
    mkdir -p $HOME/.config
    ln -s /config $HOME/.config/qBittorrent
fi

if ! [ -d "$HOME/.local/share/data/qBittorrent" ]; then
    mkdir -p $HOME/.local/share
    ln -s /data $HOME/.local/share/qBittorrent
fi

qbittorrent-nox --webui-port=8080
