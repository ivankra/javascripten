# Tiny QuickJS-NG/libuv-based runtime
#
# URL: https://github.com/saghul/txiki.js

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/saghul/txiki.js.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"
RUN git submodule update --init

RUN apt-get update -y && apt-get install -y libcurl4-openssl-dev build-essential cmake autoconf texinfo libtool libltdl-dev clang libffi-dev
RUN CC=clang CXX=clang++ CFLAGS=-Wno-stringop-overread \
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_EXTERNAL_FFI=1 && \
    ninja -C build
# ffi submodule build fails

ENV JS_BINARY=/work/build/tjs
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+.*' >version
CMD ${JS_BINARY}
