# With a recent version of docker, you can use "FROM alpine" statement 
# and it will put the right arch image, dependenting of the host which build the image
# If you ant to force the arch, you can replace "FROM alpine" by :
# for 32 bits / armhf, for all compatibility with all the rapsberry pi
#FROM arm32v6/alpine
# for 64 bits arm64 / aarch64
#FROM arm64v8/alpine
FROM alpine:3.7

# Upgrating the image first, to have the last version of all packages, and to
# share the same layer accros the images
RUN apk --no-cache upgrade \
    && apk --no-cache add \
       su-exec \
       ca-certificates

# Version
ARG MASTODON_VERSION=2.3.3

ARG YARN_VERSION=1.5.1
ARG YARN_DOWNLOAD_SHA256=cd31657232cf48d57fdbff55f38bfa058d2fb4950450bd34af72dac796af4de1

ARG LIBICONV_VERSION=1.15
ARG LIBICONV_DOWNLOAD_SHA256=ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178

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
    build-base \
    python-dev \
    protobuf-dev \
    git \
    icu-dev \
    libtool \
    libidn-dev \
    ruby-dev \
    ruby-rdoc \
    libffi-dev \
    wget \
    tar \
 && apk --no-cache add \
    nodejs-npm \
    nodejs \
    libpq \
    ffmpeg \
    file \
    icu-libs \
    libidn \
    imagemagick \
    protobuf \
    tini \
    yarn \
    ruby \
    ruby-rake \
    ruby-bigdecimal \
    ruby-io-console \
    ruby-irb \
    ruby-json \
    s6 \
    tzdata \
 && update-ca-certificates \
 && mkdir -p /tmp/src /opt \
 && wget -O yarn.tar.gz "https://github.com/yarnpkg/yarn/releases/download/v$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
 && echo "$YARN_DOWNLOAD_SHA256 *yarn.tar.gz" | sha256sum -c - \
 && tar -xzf yarn.tar.gz -C /tmp/src \
 && rm yarn.tar.gz \
 && mv /tmp/src/yarn-v$YARN_VERSION /opt/yarn \
 && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

RUN wget -O libiconv.tar.gz "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz" \
 && echo "$LIBICONV_DOWNLOAD_SHA256 *libiconv.tar.gz" | sha256sum -c - \
 && mkdir -p /tmp/src \
 && tar -xzf libiconv.tar.gz -C /tmp/src \
 && rm libiconv.tar.gz \
 && cd /tmp/src/libiconv-$LIBICONV_VERSION \
 && ./configure --prefix=/usr/local \
 && make -j$(getconf _NPROCESSORS_ONLN)\
 && make install \
 && libtool --finish /usr/local/lib

RUN cd /mastodon \
 && wget -qO- https://github.com/tootsuite/mastodon/archive/v${MASTODON_VERSION}.tar.gz | tar xz --strip 1 \
 && gem install rake -v 12.3.0 \
  && gem install bundler \
 && npm config set unsafe-perm true \
# && npm install --global yarn@0.25.2 \
 && bundle config build.nokogiri --with-iconv-lib=/usr/local/lib --with-iconv-include=/usr/local/include \
 && bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --clean --no-cache --without test development \
 && yarn --ignore-optional --pure-lockfile \
 && SECRET_KEY_BASE=$(rake secret) OTP_SECRET=$(rake secret) SMTP_FROM_ADDRESS= rake assets:precompile \
# && npm -g cache clean \ 
 && yarn cache clean \
 && mv public/assets /tmp/assets && mv public/packs /tmp/packs \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/*

RUN apk --no-cache add ruby-rdoc \
 && apk del ruby-rake \
 && gem install rake -v 12.3.0

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
