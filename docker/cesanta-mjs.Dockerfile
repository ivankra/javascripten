ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/cesanta/mjs.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN gcc -O3 -DMJS_MAIN -o mjs mjs.c

ENV JS_BINARY=/src/mjs
# No REPL
