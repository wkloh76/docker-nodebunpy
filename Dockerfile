# syntax=docker/dockerfile:1

FROM alpine:3.21 AS rootfs-stage

ARG S6_OVERLAY_VERSION="3.2.1.0"
ARG ROOTFS=/root-out
ARG REL=v3.22
ARG ARCH=x86_64
ARG MIRROR=http://dl-cdn.alpinelinux.org/alpine
ARG PACKAGES=alpine-baselayout,\
alpine-keys,\
apk-tools,\
busybox,\
libc-utils

# install packages
RUN \
  apk add --no-cache \
    bash \
    xz

# build rootfs
RUN \
  mkdir -p "${ROOTFS}/etc/apk" && \
  { \
    echo "${MIRROR}/${REL}/main"; \
    echo "${MIRROR}/${REL}/community"; \
  } > "${ROOTFS}/etc/apk/repositories" && \
  apk --root "${ROOTFS}" --no-cache --keys-dir /etc/apk/keys add --arch ${ARCH} --initdb ${PACKAGES//,/ } && \
  sed -i -e 's/^root::/root:!:/' /root-out/etc/shadow

# add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C /root-out -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz /tmp
RUN tar -C /root-out -Jxpf /tmp/s6-overlay-${ARCH}.tar.xz

# add s6 optional symlinks
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
RUN tar -C /root-out -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && unlink /root-out/usr/bin/with-contenv
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C /root-out -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

# Runtime stage
FROM scratch
COPY --from=rootfs-stage /root-out/ /
ARG BUILD_DATE
ARG VERSION
ARG MODS_VERSION="v3"
ARG PKG_INST_VERSION="v1"
ARG LSIOWN_VERSION="v1"
ARG WITHCONTENV_VERSION="v1"
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TheLamer"

ADD --chmod=755 "https://raw.githubusercontent.com/linuxserver/docker-mods/mod-scripts/docker-mods.${MODS_VERSION}" "/docker-mods"
ADD --chmod=755 "https://raw.githubusercontent.com/linuxserver/docker-mods/mod-scripts/package-install.${PKG_INST_VERSION}" "/etc/s6-overlay/s6-rc.d/init-mods-package-install/run"
ADD --chmod=755 "https://raw.githubusercontent.com/linuxserver/docker-mods/mod-scripts/lsiown.${LSIOWN_VERSION}" "/usr/bin/lsiown"
ADD --chmod=755 "https://raw.githubusercontent.com/linuxserver/docker-mods/mod-scripts/with-contenv.${WITHCONTENV_VERSION}" "/usr/bin/with-contenv"

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
  HOME="/root" \
  TERM="xterm" \
  S6_CMD_WAIT_FOR_SERVICES_MAXTIME="0" \
  S6_VERBOSITY=1 \
  S6_STAGE2_HOOK=/docker-mods \
  VIRTUAL_ENV=/lsiopy \
  PATH="/lsiopy/bin:$PATH"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    alpine-release \
    bash \
    ca-certificates \
    catatonit \
    coreutils \
    curl \
    findutils \
    jq \
    netcat-openbsd \
    procps-ng \
    shadow \
    tzdata && \
  echo "**** create bunadmin user and make our folders ****" && \
  groupmod -g 1000 users && \
  useradd -u 911 -U -d /config -s /bin/false bunadmin && \
  usermod -G users bunadmin && \
  mkdir -p \
    /app \
    /config \
    /defaults \
    /lsiopy && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

RUN \
  echo "**** install packages ****" && \
  apk add sudo \    
    git \  
    python3 \
    iproute2 \
    bash \
    xz \
    lsof \
    tar

ARG NODE_VERSION    
  RUN apk add --no-cache \
          libstdc++ \
      && apk add --no-cache --virtual .build-deps \
          curl \
      && ARCH= OPENSSL_ARCH='linux*' && alpineArch="$(apk --print-arch)" \
        && case "${alpineArch##*-}" in \
          x86_64) ARCH='x64' CHECKSUM="8a4633a9f8101de6870f7d4e5ceb3aa83d3c6cd7c11ad91cd902ea223b8c55fe" OPENSSL_ARCH=linux-x86_64;; \
          x86) OPENSSL_ARCH=linux-elf;; \
          aarch64) OPENSSL_ARCH=linux-aarch64;; \
          arm*) OPENSSL_ARCH=linux-armv4;; \
          ppc64le) OPENSSL_ARCH=linux-ppc64le;; \
          s390x) OPENSSL_ARCH=linux-s390x;; \
          *) ;; \
        esac \
    && if [ -n "${CHECKSUM}" ]; then \
      set -eu; \
      curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
      echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
        && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
        && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
    else \
      echo "Building from source" \
      # backup build
      && apk add --no-cache --virtual .build-deps-full \
          binutils-gold \
          g++ \
          gcc \
          gnupg \
          libgcc \
          linux-headers \
          make \
          python3 \
          py-setuptools \
      # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
      && export GNUPGHOME="$(mktemp -d)" \
      # gpg keys listed at https://github.com/nodejs/node#release-keys
      && for key in \
        C0D6248439F1D5604AAFFB4021D900FFDB233756 \
        DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
        CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
        C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
        108F52B48DB57BB0CC439B2997B01419BD92F80A \
        A363A499291CBBC940DD62E41F10027AF002F8B0 \
      ; do \
        gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
      done \
      && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
      && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
      && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
      && gpgconf --kill all \
      && rm -rf "$GNUPGHOME" \
      && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
      && tar -xf "node-v$NODE_VERSION.tar.xz" \
      && cd "node-v$NODE_VERSION" \
      && ./configure \
      && make -j$(getconf _NPROCESSORS_ONLN) V= \
      && make install \
      && apk del .build-deps-full \
      && cd .. \
      && rm -Rf "node-v$NODE_VERSION" \
      && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
    fi \
    && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
    # Remove unused OpenSSL headers to save ~34MB. See this NodeJS issue: https://github.com/nodejs/node/issues/46451
    && find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} \; \
    && apk del .build-deps \
    # smoke tests
    && node --version \
    && npm --version


# https://github.com/oven-sh/bun/blob/main/dockerhub/alpine/Dockerfile
ARG BUN_VERSION
RUN apk --no-cache add ca-certificates curl dirmngr gpg gpg-agent unzip openssl ncurses-libs libstdc++ \
    && arch="$(apk --print-arch)" \
    && case "${arch##*-}" in \
      x86_64) build="x64-musl-baseline";; \
      aarch64) build="aarch64-musl";; \
      *) echo "error: unsupported architecture: $arch"; exit 1 ;; \
    esac \
    && version="$BUN_VERSION" \
    && case "$version" in \
      latest | canary | bun-v*) tag="$version"; ;; \
      v*)                       tag="bun-$version"; ;; \
      *)                        tag="bun-v$version"; ;; \
    esac \
    && case "$tag" in \
      latest) release="latest/download"; ;; \
      *)      release="download/$tag"; ;; \
    esac \
    && curl "https://github.com/oven-sh/bun/releases/$release/bun-linux-$build.zip" \
      -fsSLO \
      --compressed \
      --retry 5 \
      || (echo "error: failed to download: $tag" && exit 1) \
    && for key in \
      "F3DCC08A8572C0749B3E18888EAB4D40A7B22B59" \
    ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" \
      || gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl "https://github.com/oven-sh/bun/releases/$release/SHASUMS256.txt.asc" \
      -fsSLO \
      --compressed \
      --retry 5 \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
      || (echo "error: failed to verify: $tag" && exit 1) \
    && grep " bun-linux-$build.zip\$" SHASUMS256.txt | sha256sum -c - \
      || (echo "error: failed to verify: $tag" && exit 1) \
    && unzip "bun-linux-$build.zip" \
    && mv "bun-linux-$build/bun" /usr/local/bin/bun \
    && rm -f "bun-linux-$build.zip" SHASUMS256.txt.asc SHASUMS256.txt \
    && chmod +x /usr/local/bin/bun \
    && which bun \
    && bun --version

# Install uv for python instead pip3 and pip
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# add local files
COPY root/ /
COPY scripts/ /scripts

RUN \
  bun build /scripts/install_module.js --compile --outfile /usr/local/bin/helper && \
  chmod +x /usr/local/bin/helper && \
  rm -rf \
    /scripts/install_module.js

# ports
EXPOSE 3000-3001

ENTRYPOINT ["/init"]
