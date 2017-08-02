FROM arm32v6/alpine:3.6

# Upgrating the image first, to have the last version of all packages, and to
# share the same layer accros the images
RUN apk --no-cache upgrade \
    && apk --no-cache add \
       su-exec \
       ca-certificates

# Version
ARG MASTODON_VERSION=1.5.0

ENV UID=991 GID=991 \
    RUN_DB_MIGRATIONS=true \
    SIDEKIQ_WORKERS=5 \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production \
    NODE_ENV=production \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/mastodon/bin

WORKDIR /mastodon

RUN apk --no-cache add --virtual build-dependencies \
    postgresql-dev \
    libxml2-dev \
    libxslt-dev \
    build-base \
    python-dev \
    protobuf-dev \
    git \
    ruby-dev \
    ruby-rdoc \
    libffi-dev \
    wget \
    tar \
 && apk --no-cache add \
    nodejs-current-npm \
    nodejs-current \
    libpq \
    libxml2 \
    libxslt \
    ffmpeg \
    file \
    imagemagick \
    protobuf \
    tini \
    ruby \
 	ruby-rake \
    ruby-bigdecimal \
    ruby-io-console \
    ruby-irb \
    ruby-json \
    s6 \
 && update-ca-certificates \
 && wget -qO- https://github.com/tootsuite/mastodon/archive/v${MASTODON_VERSION}.tar.gz | tar xz --strip 1 \
 && gem install bundler \
 && bundle install --deployment --clean --no-cache --without test development \
 && npm install -g npm@3 && npm install -g yarn \
# Rebuild to support arm architecture
 && npm rebuild node-sass \
 && yarn --ignore-optional --pure-lockfile \
 && SECRET_KEY_BASE=$(rake secret) rake assets:precompile \
 && npm -g cache clean && yarn cache clean \
 && mv public/assets /tmp/assets && mv public/packs /tmp/packs \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/*

COPY rootfs /

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

VOLUME /mastodon/public/system /mastodon/public/assets /mastodon/public/packs /mastodon/log

LABEL maintainer="julien@lavergne.online" \
      description="A GNU Social-compatible microblogging server" \
      mastodon_version="${MASTODON_VERSION}" \
      project_url="https://github.com/tootsuite/mastodon" \
      original_maintainer="Wonderfall <wonderfall@targaryen.house>"

EXPOSE 3000 4000

ENTRYPOINT ["/usr/local/bin/run"]

CMD ["/bin/s6-svscan", "/etc/s6.d"]
