ARG BASE=jsz-golang
FROM $BASE

ARG REPO=https://github.com/dop251/goja.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN cd goja && go build

ENV JS_BINARY=/src/goja/goja
CMD ${JS_BINARY}
