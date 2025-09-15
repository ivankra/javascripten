FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/cesanta/mjs.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN gcc -O2 -DMJS_MAIN -o mjs mjs.c

ENV JS_BINARY=/work/mjs
# No REPL
