FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/doodlewind/mocha1995
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN bash -c 'source ./build.sh && compile_native'

ENV JS_BINARY=/work/out/mo_shell
CMD ${JS_BINARY}
