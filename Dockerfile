FROM gilir/rpi-ruby

# Upgrating the image first, to have the last version of all packages, and to
# share the same layer accros the images
RUN apk --no-cache upgrade \
    && apk --no-cache add \
       su-exec \
       ca-certificates

# Version
ARG MASTODON_VERSION=1.4.1

ENV UID=991 GID=991 \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production NODE_ENV=production

ADD https://github.com/tootsuite/mastodon/archive/v${MASTODON_VERSION}.tar.gz .

COPY docker_entrypoint.sh /usr/local/bin/run

RUN tar -xvf v${MASTODON_VERSION}.tar.gz \
 && mkdir -p /tmp/mastodon/build/ \
 && mv mastodon-*/* /tmp/mastodon/build/ \
 && mv mastodon-*/.[^\.]* /tmp/mastodon/build/ \
 && rm -f v${MASTODON_VERSION}.tar.gz \
 && rm -rf mastodon-*/ \
 && mkdir /mastodon \
 && cd mastodon/ \
 && cp /tmp/mastodon/build/Gemfile . \
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
    protobuf-dev \
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
    protobuf \
    tini \
 && npm install -g npm@3 && npm install -g yarn \
# Rebuild to support arm architecture
 && npm rebuild node-sass \
 && bundle install --deployment --without test development \
 && yarn --ignore-optional --pure-lockfile \
 && yarn cache clean \
 && npm -g cache clean \
 && update-ca-certificates \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* \
 && cp -r /tmp/mastodon/build/* . \
 && cp -r /tmp/mastodon/build/.[^\.]* . \
 && rm -rf /tmp/mastodon/ \
 && rm -rf /tmp/* \
 && chmod +x /usr/local/bin/run

WORKDIR /mastodon

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs

LABEL maintainer="julien@lavergne.online" \
      description="A GNU Social-compatible microblogging server" \
      mastodon_version="${MASTODON_VERSION}" \
      project_url="https://github.com/tootsuite/mastodon"

EXPOSE 3000 4000

ENTRYPOINT ["/usr/local/bin/run"]
