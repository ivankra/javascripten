ARG BASE=jszoo-gcc
FROM $BASE

ARG REPO=https://github.com/bellard/quickjs.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN ARGS=$(bash -c '[[ "$CC" == *clang* ]] && echo CONFIG_CLANG=y'); \
    make -j $ARGS

ENV JS_BINARY=/src/qjs
CMD ${JS_BINARY}
