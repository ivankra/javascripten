FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        findutils \
        less \
        libedit-dev \
        libicu-dev \
        libpcre2-dev \
        libreadline-dev \
        locales \
        lsb-release \
        make \
        openjdk-25-jdk-headless \
        python3 \
        sudo \
        tar \
        vim \
        wget \
        xz-utils \
        zip && \
    echo "en_US.UTF-8 UTF-8" >/etc/locale.gen && \
    locale-gen

# Install latest node and npm (https://nodejs.org/en/download)
#RUN export NVM_DIR=/opt/nvm && mkdir -p "$NVM_DIR" && \
#    curl -o /opt/nvm-install.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh && \
#    echo "2d8359a64a3cb07c02389ad88ceecd43f2fa469c06104f92f98df5b6f315275f  /opt/nvm-install.sh" | sha256sum -c && \
#    bash /opt/nvm-install.sh && \
#    bash -c 'source /opt/nvm/nvm.sh && nvm install node' && \
#    ln -s /opt/nvm/versions/node/*/ /opt/node
#ENV PATH=/opt/node/bin:$PATH

# Install other popular runtimes from npm:
#   * bun: JavaScriptCore-based JS/TS runtime written in Zig (https://github.com/oven-sh/bun)
#   * deno: V8/tokio-based JS/TS runtime written in Rust (https://github.com/denoland/deno)
#   * bare: V8/libuv-based runtime (https://github.com/holepunchto/bare)
#RUN npm install -g bun deno bare && \
#    (echo '' | bun repl >/dev/null 2>&1 || true)

# LLRT: lightweight QuickJS/tokio-based runtime.
# https://github.com/awslabs/llrt
#RUN cd /opt && wget "https://github.com/awslabs/llrt/releases/download/v0.7.0-beta/llrt-linux-$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/').zip" && \
#    unzip llrt*.zip && rm -f llrt*.zip && mv llrt /usr/local/bin

# RingoJS: Rhino-based runtime for JVM.
# https://github.com/ringo/ringojs
#RUN cd /opt && wget "https://github.com/ringo/ringojs/releases/download/v4.0.0/ringojs-4.0.0.tar.gz" && \
#    tar xf ringojs*.tar.gz && \
#    echo >/usr/local/bin/ringojs \
#      '#!/bin/sh'"\n" \
#      'java -jar /opt/ringo*/run.jar "$@"' && \
#    chmod a+rx /usr/local/bin/ringojs

WORKDIR /dist
