# docker_qbittorrent-nox <a href='https://github.com/padhi-homelab/docker_qbittorrent-nox/actions?query=workflow%3A%22Docker+CI+Release%22'><img align='right' src='https://img.shields.io/github/workflow/status/padhi-homelab/docker_qbittorrent-nox/Docker%20CI%20Release?logo=github&logoWidth=24&style=flat-square'></img></a>

<a href='https://microbadger.com/images/padhihomelab/qbittorrent-nox'><img src='https://img.shields.io/microbadger/layers/padhihomelab/qbittorrent-nox/latest?logo=docker&logoWidth=24&style=for-the-badge'></img></a>
<a href='https://hub.docker.com/r/padhihomelab/qbittorrent-nox'><img src='https://img.shields.io/docker/image-size/padhihomelab/qbittorrent-nox/latest?label=size%20%5Blatest%5D&logo=docker&logoWidth=24&style=for-the-badge'></img></a>

A multiarch [qBittorrent] Docker image, based on [Alpine Linux], with level 1,2,3 IPFilter [block lists].

|        386         |       amd64        |       arm/v6       |       arm/v7       |       arm64        |      ppc64le       |       s390x        |
| :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: |
| :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |



## Usage

```
docker run --rm --detach \
           -p 8080:8080 \
           -e DOCKER_UID=`id -u` \
           -v /path/to/finished/downloads:/data/complete \
           -v /path/to/incomplete/downloads:/data/incomplete \
           -it padhihomelab/qbittorrent-nox
```

Runs `qbittorrent` with WebUI served on port 8080.

_<More details to be added soon>_


[Alpine Linux]: https://alpinelinux.org/
[qBittorrent]:  https://www.qbittorrent.org/

[block lists]:  https://www.iblocklist.com/lists