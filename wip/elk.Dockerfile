# Low-footprint JavaScript interpreter for microcontrollers.
# Toy interpreter that can hardly run any JavaScript: `'var' not implemented`.
#
# URL:      https://github.com/cesanta/elk
# Standard: non-compliant
# Tech:     interprets from source
# Language: C
# Timeline: 2019-
# License:  AGPL

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/cesanta/elk.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN gcc -o elk -O2 -I. -DJS_DUMP elk.c examples/cmdline/main.c

ENV JS_BINARY=/work/elk
# No REPL, no script running - pass expression on command-line.
