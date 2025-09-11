# JavaScript engine for microcontrollers.
#
# URL:      https://github.com/cesanta/v7
# Standard: ES5 (subset)
# Tech:     stack VM
# Language: C
# License:  GPL-2.0
# LOC:      24811 (cloc v7.c v7.h)
# Timeline: 2013-2017

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/cesanta/v7.git
ARG JS_COMMIT=ce5212ae42dfd93247c56fbc233f65367e9def27

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN gcc -o v7 -O3 -DV7_LARGE_AST -DV7_EXE -DCS_ENABLE_UTF8 v7.c -lm

ENV JS_BINARY=/work/v7
# No REPL
