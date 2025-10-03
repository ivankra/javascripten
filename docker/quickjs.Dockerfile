ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/bellard/quickjs.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN make -j $(bash -c '[[ "$CC" == *clang* ]] && echo CONFIG_CLANG=y')

ENV JS_BINARY=/src/qjs
CMD ${JS_BINARY}
