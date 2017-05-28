#!/bin/sh
docker-compose run --rm mastodon-web rake mastodon:daily
