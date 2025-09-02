# JavaScript engine for microcontrollers.
# Unfinished: `[var] is not implemented`.
#
# URL:      https://github.com/cesanta/mjs
# Standard: non-compliant
# Tech:     stack-based VM
# Language: C
# Timeline: 2016-
# License:  GPL-2.0

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/cesanta/mjs.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN gcc -O2 -DMJS_MAIN -o mjs mjs.c

ENV JS_BINARY=/work/mjs
# No REPL
