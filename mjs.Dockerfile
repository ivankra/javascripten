# JavaScript engine for microcontrollers.
#
# URL:      https://github.com/cesanta/mjs
# Standard: no
# Tech:     stack VM
# Language: C
# License:  GPL-2.0
# LOC:      33845 (cloc src)
# Timeline: 2016-
# Note:     Can't run test suite: '[var] is not implemented'.

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/cesanta/mjs.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN gcc -O2 -DMJS_MAIN -o mjs mjs.c

ENV JS_BINARY=/work/mjs
# No REPL
