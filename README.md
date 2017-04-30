# Mastodon - Docker ARM builds for Raspberry PI
[![Docker Stars](https://img.shields.io/docker/stars/gilir/rpi-mastodon.svg?maxAge=2592000)](https://hub.docker.com/r/gilir/rpi-mastodon/)[![Docker Pulls](https://img.shields.io/docker/pulls/gilir/rpi-mastodon.svg?maxAge=2592000)](https://hub.docker.com/r/gilir/rpi-mastodon/)[![Docker Image](https://images.microbadger.com/badges/image/gilir/rpi-mastodon.svg)](https://microbadger.com/images/gilir/rpi-mastodon "Get your own image badge on microbadger.com")[![Version](https://images.microbadger.com/badges/version/gilir/rpi-mastodon.svg)](https://microbadger.com/images/gilir/rpi-mastodon "Get your own version badge on microbadger.com")


## About Mastodon
[Mastodon](https://github.com/tootsuite/mastodon) is a free, open-source social network server. A decentralized solution to commercial platforms, it avoids the risks of a single company monopolizing your communication. Anyone can run Mastodon and participate in the social network seamlessly.

An alternative implementation of the GNU social project. Based on [ActivityStreams](https://en.wikipedia.org/wiki/Activity_Streams_(format)), [Webfinger](https://en.wikipedia.org/wiki/WebFinger), [PubsubHubbub](https://en.wikipedia.org/wiki/PubSubHubbub) and [Salmon](https://en.wikipedia.org/wiki/Salmon_(protocol)).

## ARM build, for Raspberry PI
Based on upstream version of Dockerbuild. See Tags for the versions available.

## Features
- Alpine 3.5
- Ruby 2.4.1

## How to use

Please refer to the [upstream docker instructions](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Docker-Guide.md).

Mastodon need several services to run properly :
- Postgres (you can use this image: armhf/postgres:9.6-alpine)
- Redis (you can use this image: armhf/redis)

# Sources
- Gogs: https://gogs.lavergne.online/gilir/rpi-mastodon.git
- Github: https://github.com/gilir/rpi-mastodon
