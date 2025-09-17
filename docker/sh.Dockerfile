FROM javascripten-debian:stable

RUN apt-get update -y && apt-get install -y --no-install-recommends \
        libedit-dev \
        libicu-dev \
        libpcre2-dev \
        libreadline-dev \
        openjdk-25-jdk-headless \
        # Guile has a primitive unfinished ES3 engine, run 'guile --language=ecmascript' \
        guile-3.0 \
        # Rhino: slow engine shipped with early JDK versions \
        rhino

# GraalJS
RUN cd /opt && wget "https://github.com/oracle/graaljs/releases/download/graal-24.2.2/graaljs-24.2.2-linux-$(uname -m | sed -e 's/x86_64/amd64/').tar.gz" && \
    tar xf graaljs*.tar.gz && \
    ln -s /opt/graal*/bin/js /usr/local/bin/graaljs

# Install node/npm and some popular JavaScript runtimes:
#
#   * node: V8/libuv-based runtime.
#     https://github.com/nodejs/node
#   * bun: JavaScriptCore-based JS/TS runtime written in Zig.
#     https://github.com/oven-sh/bun
#   * deno: V8/tokio-based JS/TS runtime written in Rust.
#     https://github.com/denoland/deno
#   * bare: V8/libuv-based runtime.
#     https://github.com/holepunchto/bare
#   * LLRT: lightweight QuickJS/tokio-based runtime.
#     https://github.com/awslabs/llrt
#   * RingoJS: Rhino-based runtime for JVM.
#     https://github.com/ringo/ringojs

# Debian's nodejs is a few release behind
#RUN apt-get install -y --no-install-recommends nodejs npm

# https://nodejs.org/en/download
RUN export NVM_DIR=/opt/nvm && mkdir -p "$NVM_DIR" && \
    curl -o /opt/nvm-install.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh && \
    echo "2d8359a64a3cb07c02389ad88ceecd43f2fa469c06104f92f98df5b6f315275f  /opt/nvm-install.sh" | sha256sum -c && \
    bash /opt/nvm-install.sh && \
    bash -c 'source /opt/nvm/nvm.sh && nvm install node' && \
    ln -s /opt/nvm/versions/node/*/ /opt/node
ENV PATH=/opt/node/bin:$PATH

# Install most other runtimes from npm
RUN npm install -g bun deno bare
RUN echo '' | bun repl >/dev/null 2>&1 || true

# LLRT
RUN cd /opt && wget "https://github.com/awslabs/llrt/releases/download/v0.6.2-beta/llrt-linux-$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/').zip" && \
    unzip llrt*.zip && mv llrt /usr/local/bin

# RingoJS
RUN cd /opt && wget "https://github.com/ringo/ringojs/releases/download/v4.0.0/ringojs-4.0.0.tar.gz" && \
    tar xf ringojs*.tar.gz && \
    echo >/usr/local/bin/ringojs \
      '#!/bin/sh'"\n" \
      'java -jar /opt/ringo*/run.jar "$@"' && \
    chmod a+rx /usr/local/bin/ringojs

WORKDIR /work
