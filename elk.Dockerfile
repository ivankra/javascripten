# Low-footprint JavaScript interpreter for microcontrollers.
# Toy interpreter that can hardly run any JavaScript.
#
# URL:      https://github.com/cesanta/elk
# Standard: no
# Tech:     interprets from source
# Language: C
# License:  AGPL
# LOC:      1247 (cloc elk.c elk.h)
# Timeline: 2019-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/cesanta/elk.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN gcc -o elk -O2 -I. -DJS_DUMP elk.c examples/cmdline/main.c

ENV JS_BINARY=/work/elk
# No REPL, no script running - pass expression on command-line.
