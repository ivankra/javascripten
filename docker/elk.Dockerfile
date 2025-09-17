FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/cesanta/elk.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN gcc -o elk -O2 -I. -DJS_DUMP elk.c examples/cmdline/main.c

ENV JS_BINARY=/work/elk
# No REPL, no script running - pass expression on command-line.
