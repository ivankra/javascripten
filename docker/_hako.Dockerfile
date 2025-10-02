FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/andrewmd5/hako
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"
RUN git submodule update --init

RUN ./tools/envsetup.sh && ./tools/build.sh
# only x64. cmake 4.0+

ENV JS_BINARY=/work/qjs
CMD ${JS_BINARY}
