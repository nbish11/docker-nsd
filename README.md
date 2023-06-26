# docker-nsd

[NSD](https://nlnetlabs.nl/projects/nsd/about/) as a docker image. This repository is a proof of concept and I am hoping to get it merged into the official NSD repository.

## About

>The NLnet Labs Name Server Daemon (NSD) is an authoritative DNS name server. It has been developed for operations in environments where speed, reliability, stability and security are of high importance.

It is RFC compliant and has been primarily developed to provide a modern alternative to BIND, while remaining compatible with BIND configuration files. This makes NSD perfect for TLD implementations, root servers, and anyone needing fast and optimized authoritative name serving.

There is no official NSD docker image, so I created this one. (I have opened an issue on the official NSD github repository [Official Docker Image #285](https://github.com/NLnetLabs/nsd/issues/285) to ask to merge this.) This image is based on Alpine Linux and builds NSD from source in the image.

## Usage

This image only requires one volume to be mounted: `/nsd`. This is where the configuration file and zone files will be stored. The configuration file is expected to be named `nsd.conf` and the zone files are expected to be in a directory named `zones`. You will find the log `log.txt` in the `/nsd` directory as well. If no configuration file is found, a default one will be created.

There is an experimental build time option called `lower_memory_footprint` that will attempt to lower NSD's memory usage in the container. Use with caution.

To build:

```sh
$ docker build -t nsd .
```

To run:

```sh
$ docker run -it -p 53:53/udp -p 53:53/tcp -v /path/to/nsd:/nsd --name nsd nsd
```
