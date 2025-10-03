ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/cesanta/elk.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN gcc -o elk -O3 -I. -DJS_DUMP elk.c examples/cmdline/main.c

ENV JS_BINARY=/src/elk
# No REPL, no script running - pass expression on command-line.
