# docker_qbittorrent-nox <a href='https://github.com/padhi-homelab/docker_qbittorrent-nox/actions?query=workflow%3A%22Docker+CI+Release+%28Latest%29%22'><img align='right' src='https://img.shields.io/github/actions/workflow/status/padhi-homelab/docker_qbittorrent-nox/docker-release-latest.yml?branch=master&logo=github&logoWidth=24&style=flat-square'></img></a> <a href='https://github.com/padhi-homelab/docker_qbittorrent-nox/actions?query=workflow%3A%22Docker+CI+Release+%28Core%29%22'><img align='right' src='https://img.shields.io/github/actions/workflow/status/padhi-homelab/docker_qbittorrent-nox/docker-release-core.yml?branch=master&logo=github&logoWidth=24&style=flat-square'></img></a>

<a href='https://hub.docker.com/r/padhihomelab/qbittorrent-nox'><img src='https://img.shields.io/docker/image-size/padhihomelab/qbittorrent-nox/latest?label=size%20%5Blatest%5D&logo=docker&logoWidth=24&style=for-the-badge'></img></a>
<a href='https://hub.docker.com/r/padhihomelab/qbittorrent-nox'><img src='https://img.shields.io/docker/image-size/padhihomelab/qbittorrent-nox/latest-core?label=size%20%5Bcore%5D&logo=docker&logoWidth=24&style=for-the-badge'></img></a>

A multiarch [qBittorrent] Docker image, based on [Alpine Linux], with level 1,2,3 IPFilter [block lists].

|           386            |       amd64        |          arm/v6          |       arm/v7       |       arm64        |         ppc64le          |          s390x           |
| :----------------------: | :----------------: | :----------------------: | :----------------: | :----------------: | :----------------------: | :----------------------: |
| :heavy_multiplication_x: | :heavy_check_mark: | :heavy_multiplication_x: | :heavy_check_mark: | :heavy_check_mark: | :heavy_multiplication_x: | :heavy_multiplication_x: |

_The `-core` images contain IPFilter block lists,_
_but no `python3` (needed for search plugins) and no `tzdata`._

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
