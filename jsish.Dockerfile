# Small embeddable JavaScript interpreter.
#
# URL:      https://github.com/pcmacdon/jsish
# Standard: no
# Tech:     stack-based VM
# Language: C
# License:  MIT
# LOC:      50896 (cloc src)
# Timeline: 2020-2022
# Note:     Can't run test suite - bugs in ASI, != operator, no Date class.

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/pcmacdon/jsish.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN CFLAGS=-O2 make -j1

ENV JS_BINARY=/work/jsish
CMD ${JS_BINARY}
