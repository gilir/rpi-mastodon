FROM gilir/rpi-ruby

# Upgrating the image first, to have the last version of all packages, and to
# share the same layer accros the images
RUN apk --no-cache upgrade \
    && apk --no-cache add \
       su-exec \
       ca-certificates

# Version
ARG MASTODON_VERSION=1.3.2

ENV RAILS_ENV=production \
    NODE_ENV=production

ADD https://github.com/tootsuite/mastodon/archive/v${MASTODON_VERSION}.tar.gz .

RUN tar -xvf v${MASTODON_VERSION}.tar.gz \
 && mkdir -p /tmp/mastodon/build/ \
 && mv mastodon-*/* /tmp/mastodon/build/ \
 && rm -f v${MASTODON_VERSION}.tar.gz \

WORKDIR /mastodon

RUN cp /tmp/mastodon/build/Gemfile . \
 && cp /tmp/mastodon/build/Gemfile.lock . \
 && cp /tmp/mastodon/build/package.json . \
 && cp /tmp/mastodon/build/Gemfile.lock . \
 && echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && apk --no-cache add --virtual build-dependencies \
    postgresql-dev \
    libxml2-dev \
    libxslt-dev \
    build-base \
    python-dev \
    git \
# Can't use no--cache with @edge
 && apk -U upgrade && apk add \
    nodejs@edge \
    nodejs-npm@edge \
    libpq \
    libxml2 \
    libxslt \
    ffmpeg \
    file \
    imagemagick@edge \
 && npm install -g npm@3 && npm install -g yarn \
 && bundle install --deployment --without test development \
 && yarn --ignore-optional \
 && yarn cache clean \
 && npm -g cache clean \
 && update-ca-certificates \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* \
 && cp -r /tmp/mastodon/build/* . \
 && rm -rf /tmp/mastodon/

VOLUME /mastodon/public/system /mastodon/public/assets

LABEL maintainer="julien@lavergne.online" \
      description="A GNU Social-compatible microblogging server" \
      mastodon_version="${MASTODON_VERSION}" \
      project_url="https://github.com/tootsuite/mastodon"

EXPOSE 3000 4000
