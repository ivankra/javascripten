# Small embeddable JavaScript interpreter.
# Can't run tests: buggy (ASI, !=), no Date.
#
# URL:      https://github.com/pcmacdon/jsish
# Standard: non-compliant
# Tech:     stack-based VM
# Language: C
# Timeline: 2020-2022
# License:  MIT

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/pcmacdon/jsish.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN CFLAGS=-O2 make -j1

ENV JS_BINARY=/work/jsish
CMD ${JS_BINARY}
