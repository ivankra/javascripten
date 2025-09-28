FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/espruino/Espruino.git
ARG JS_REV=master

WORKDIR /src
RUN git clone "$JS_REPO" . && git checkout "$JS_REV"

RUN make -j RELEASE=1

ENV JS_BINARY=/src/bin/espruino
RUN ${JS_BINARY} -e 'print(process.version)' | tail -2 | head -1 | tr -d '\r' >version
CMD ${JS_BINARY}
