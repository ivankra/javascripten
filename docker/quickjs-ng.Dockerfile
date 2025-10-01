ARG BASE=jszoo-gcc
FROM $BASE

ARG REPO=https://github.com/quickjs-ng/quickjs.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN make -j

ENV JS_BINARY=/src/build/qjs
CMD ${JS_BINARY}
