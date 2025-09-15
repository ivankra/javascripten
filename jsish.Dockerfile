FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/pcmacdon/jsish.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN CFLAGS=-O2 make -j1

ENV JS_BINARY=/work/jsish
CMD ${JS_BINARY}
