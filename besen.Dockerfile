FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/BeRo1985/besen.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends fpc
RUN fpc -O3 src/BESENShell.lpr

ENV JS_BINARY=/work/src/BESENShell
CMD ${JS_BINARY}
