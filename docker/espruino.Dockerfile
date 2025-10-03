ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/espruino/Espruino.git
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN make -j RELEASE=1

ENV JS_BINARY=/src/bin/espruino
RUN ${JS_BINARY} -e 'print(process.version)' | tail -2 | head -1 | tr -d '\r' >jsz_version
CMD ${JS_BINARY}
