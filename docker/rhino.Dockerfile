ARG BASE=jsz-debian
FROM $BASE

ARG REPO=https://github.com/mozilla/rhino
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

# Build fails with JDK 25
RUN apt-get install -y --no-install-recommends openjdk-21-jdk-headless

RUN ./gradlew :rhino-all:build

RUN VERSION=$(git describe --tags | sed -Ee 's/^Rhino([0-9_]+)_Release/\1/; s/_/./g') && \
    mkdir -p /dist && \
    cp rhino-all/build/libs/rhino-all-*.jar /dist && \
    echo >/dist/rhino \
      '#!/bin/bash'"\n" \
      'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" '"\n" \
      'java -jar "$SCRIPT_DIR/'$(cd /dist; ls rhino-all-*.jar)'" "$@"' && \
    chmod a+rx /dist/rhino && \
    echo "$VERSION" >jsz_version && \
    du -bs /dist/rhino-all-*.jar | cut -f 1 >jsz_binary_size

ENV JS_BINARY=/dist/rhino
CMD ${JS_BINARY}
