FROM gilir/rpi-ruby-alpine

ENV MASTODON_VERSION 1.3.1

LABEL maintainer="julien@lavergne.online" \
      description="A GNU Social-compatible microblogging server" \
      mastodon_version="${MASTODON_VERSION}" \
      project_url="https://github.com/tootsuite/mastodon"

ENV RAILS_ENV=production \
    NODE_ENV=production

EXPOSE 3000 4000

RUN apk -U upgrade && apk add git

WORKDIR /tmp/mastodon/build

RUN git clone https://github.com/tootsuite/mastodon.git . && git checkout tags/v${MASTODON_VERSION} && pwd && ls

WORKDIR /mastodon

RUN cp /tmp/mastodon/build/Gemfile /mastodon/ \ 
 && cp /tmp/mastodon/build/Gemfile.lock /mastodon/ \ 
 && cp /tmp/mastodon/build/package.json /mastodon/ \
 && cp /tmp/mastodon/build/Gemfile.lock /mastodon/ \
 && echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && BUILD_DEPS=" \
    postgresql-dev \
    libxml2-dev \
    libxslt-dev \
    build-base \
    python-dev \
    git" \
 && apk -U upgrade && apk add \
    $BUILD_DEPS \
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
 && apk del $BUILD_DEPS \
 && rm -rf /var/cache/apk/* \
 && cp -r /tmp/mastodon/build/* /mastodon \
 && rm -rf /tmp/*

VOLUME /mastodon/public/system /mastodon/public/assets
