ARG BASE=jsz-debian
FROM $BASE

ARG REPO=https://github.com/oracle/graaljs
ARG REV=graal-25.0.0

# Download pre-built release

WORKDIR /dist
RUN wget "https://github.com/oracle/graaljs/releases/download/$REV/$(echo "$REV" | sed -e 's/graal/graaljs/')-linux-$(uname -m | sed -e 's/x86_64/amd64/').tar.gz" && \
    tar xf graaljs-*.tar.gz && \
    rm -f graaljs-*.tar.gz && \
    # Don't use symlinks - docker's COPY will f them up \
    echo >/dist/graaljs \
      '#!/bin/bash'"\n" \
      'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" '"\n" \
      '"$SCRIPT_DIR/'$(echo graaljs-*)'/bin/js" "$@"' && \
    chmod a+rx /dist/graaljs && \
    /dist/graaljs --version | egrep -o '[0-9.]+' >jsz_version && \
    du -bs /dist/graaljs-*| cut -f 1 >jsz_binary_size

ENV JS_BINARY=/dist/graaljs
CMD ${JS_BINARY}
