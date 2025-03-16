# docker_qbittorrent-nox

[![build status](https://img.shields.io/github/actions/workflow/status/padhi-homelab/docker_qbittorrent-nox/docker-release-latest.yml?label=BUILD&branch=main&logo=github&logoWidth=24&style=flat-square)](https://github.com/padhi-homelab/docker_qbittorrent-nox/actions/workflows/docker-release-latest.yml)
[![testing size](https://img.shields.io/docker/image-size/padhihomelab/qbittorrent-nox/testing?label=SIZE%20%5Btesting%5D&logo=docker&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/qbittorrent-nox/tags)
[![leech size](https://img.shields.io/docker/image-size/padhihomelab/qbittorrent-nox/latest-leech?label=SIZE%20%5Blatest-leech%5D&logo=docker&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/qbittorrent-nox/tags)
[![latest size](https://img.shields.io/docker/image-size/padhihomelab/qbittorrent-nox/latest?label=SIZE%20%5Blatest%5D&logo=docker&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/qbittorrent-nox/tags)
  
[![latest version](https://img.shields.io/docker/v/padhihomelab/qbittorrent-nox/latest?label=LATEST&logo=linux-containers&logoWidth=20&labelColor=darkmagenta&color=gold&style=for-the-badge)](https://hub.docker.com/r/padhihomelab/qbittorrent-nox/tags)
[![image pulls](https://img.shields.io/docker/pulls/padhihomelab/qbittorrent-nox?label=PULLS&logo=data:image/svg%2bxml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCAzMiAzMiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZyBmaWxsPSIjZmZmIj4KICAgIDxwYXRoIGQ9Ik0yMC41ODcsMTQuNjEzLDE4LDE3LjI0NlY5Ljk4QTEuOTc5LDEuOTc5LDAsMCwwLDE2LjAyLDhoLS4wNEExLjk3OSwxLjk3OSwwLDAsMCwxNCw5Ljk4djYuOTYzbC0uMjYtLjA0Mi0yLjI0OC0yLjIyN2EyLjA5MSwyLjA5MSwwLDAsMC0yLjY1Ny0uMjkzQTEuOTczLDEuOTczLDAsMCwwLDguNTgsMTcuNGw2LjA3NCw2LjAxNmEyLjAxNywyLjAxNywwLDAsMCwyLjgzMywwbDUuOTM0LTZhMS45NywxLjk3LDAsMCwwLDAtMi44MDZBMi4wMTYsMi4wMTYsMCwwLDAsMjAuNTg3LDE0LjYxM1oiLz4KICAgIDxwYXRoIGQ9Ik0xNiwwQTE2LDE2LDAsMSwwLDMyLDE2LDE2LDE2LDAsMCwwLDE2LDBabTAsMjhBMTIsMTIsMCwxLDEsMjgsMTYsMTIuMDEzLDEyLjAxMywwLDAsMSwxNiwyOFoiLz4KICA8L2c+Cjwvc3ZnPgo=&logoWidth=20&labelColor=teal&color=gold&style=for-the-badge)](https://hub.docker.com/r/padhihomelab/qbittorrent-nox)

---

A multiarch [qBittorrent] Docker image, based on [Alpine Linux], with level 1,2,3 IPFilter [block lists].

|           386            |       amd64        |          arm/v6          |       arm/v7       |       arm64        |         ppc64le          |          s390x           |
| :----------------------: | :----------------: | :----------------------: | :----------------: | :----------------: | :----------------------: | :----------------------: |
| :heavy_multiplication_x: | :heavy_check_mark: | :heavy_multiplication_x: | :heavy_check_mark: | :heavy_check_mark: | :heavy_multiplication_x: | :heavy_multiplication_x: |

> [!WARNING]  
>
> The _`-leech` images_ contain patches that disable ALL uploads.
> The builds are only intended for testing purposes;
> trackers WILL BAN YOU if you use these builds.

## Usage

```
docker run --detach \
           --name qbittorrent-nox \
           -p 8080:8080 \
           -e DOCKER_UID=`id -u` \
           -v /path/to/store/config:/config \
           -v /path/to/store/data/and/logs:/data \
           -v /path/to/finished/downloads:/torrents/complete \
           -v /path/to/incomplete/downloads:/torrents/incomplete \
           --restart=unless-stopped \
           -it padhihomelab/qbittorrent-nox
```

Runs `qbittorrent` with WebUI served on port 8080.

The default login is:
- username = `admin`
- password = `adminadmin`

_<More details to be added soon>_


[Alpine Linux]: https://alpinelinux.org/
[block lists]:  https://www.iblocklist.com/lists
[qBittorrent]:  https://www.qbittorrent.org/
