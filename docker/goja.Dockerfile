FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/dop251/goja.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y golang
RUN cd goja && go build

ENV JS_BINARY=/work/goja/goja
CMD ${JS_BINARY}
