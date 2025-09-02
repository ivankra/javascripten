# Community-oriented fork of QuickJS.
#
# URL:      https://quickjs-ng.github.io/quickjs/
# Standard: ES2023
# Tech:     stack VM, hidden classes, refcounting GC
# Language: C
# License:  MIT
# LOC:      74458 (cloc *.c *.h)
# Timeline: 2023-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/quickjs-ng/quickjs.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN make -j

ENV JS_BINARY=/work/build/qjs
CMD ${JS_BINARY}
