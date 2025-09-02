# Lightweight embeddable JavaScript engine by Fabrice Bellard and Charlie Gordon.
#
# URL:      https://bellard.org/quickjs/
# Standard: ES2023
# Tech:     stack VM, hidden classes, refcounting GC
# Language: C
# License:  MIT
# LOC:      73590 (cloc *.c *.h)
# Timeline: 2019-
#
# VM: JS_CallInternal https://github.com/bellard/quickjs/blob/master/quickjs.c#L16845

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/bellard/quickjs.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN make -j

ENV JS_BINARY=/work/qjs
CMD ${JS_BINARY}
