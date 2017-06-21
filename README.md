# Mastodon - Docker ARM builds for Raspberry PI
[![Docker Stars](https://img.shields.io/docker/stars/gilir/rpi-mastodon.svg?maxAge=2592000)](https://hub.docker.com/r/gilir/rpi-mastodon/)[![Docker Pulls](https://img.shields.io/docker/pulls/gilir/rpi-mastodon.svg?maxAge=2592000)](https://hub.docker.com/r/gilir/rpi-mastodon/)[![Docker Image](https://images.microbadger.com/badges/image/gilir/rpi-mastodon.svg)](https://microbadger.com/images/gilir/rpi-mastodon "Get your own image badge on microbadger.com")[![Version](https://images.microbadger.com/badges/version/gilir/rpi-mastodon.svg)](https://microbadger.com/images/gilir/rpi-mastodon "Get your own version badge on microbadger.com")


## About Mastodon
[Mastodon](https://github.com/tootsuite/mastodon) is a free, open-source social network server. A decentralized solution to commercial platforms, it avoids the risks of a single company monopolizing your communication. Anyone can run Mastodon and participate in the social network seamlessly.

An alternative implementation of the GNU social project. Based on [ActivityStreams](https://en.wikipedia.org/wiki/Activity_Streams_(format)), [Webfinger](https://en.wikipedia.org/wiki/WebFinger), [PubsubHubbub](https://en.wikipedia.org/wiki/PubSubHubbub) and [Salmon](https://en.wikipedia.org/wiki/Salmon_(protocol)).

## ARM build, for Raspberry PI
Based on upstream version of Dockerbuild. See Tags for the versions available.

## Features
- Alpine 3.6
- NodeJS 7.10
- Ruby 2.4.1

## How to use

Starting from 1.4.3, this image is based on Wonderfall image, [instruction are here](https://github.com/Wonderfall/dockerfiles/tree/master/mastodon).

This is quick How-To, to make your instance working :
- Clone this git repository
- Copy .env.production.example to .env.production
- Use the docker-compose.yml.example as a starting point (you can copy it to docker-compose.yml and run it unmodified, for testing)
- Run `docker-compose run --rm web rake secret`, 3 times, to replace the values in .env.production of PAPERCLIP_SECRET, SECRET_KEY_BASE and OTP_SECRET.
- Modifiy others values if you need (refer to upstream documentation for more details).
- Run `docker-compose run --rm web rake db:migrate`
- Run `docker-compose up -d`

Mastodon need several services to run properly (included in the docker-compose.yml example) :
- Postgres (you can use this image: armhf/postgres:9.6-alpine)
- Redis (you can use this image: armhf/redis)

Be sure to add volume persistence for production use (see `volumes` in docker-compose.yml for example).

Please refer to the [upstream documentation](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Administration-guide.md) for more information about the maintenance.

# Sources
- Gogs: https://gogs.lavergne.online/gilir/rpi-mastodon.git
- Github: https://github.com/gilir/rpi-mastodon
