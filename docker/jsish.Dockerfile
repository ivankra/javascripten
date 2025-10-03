ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/pcmacdon/jsish.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN CFLAGS="-O3" make -j1

ENV JS_BINARY=/src/jsish
CMD ${JS_BINARY}
