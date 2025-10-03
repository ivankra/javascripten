# Tiny QuickJS-NG/libuv-based runtime
#
# URL: https://github.com/saghul/txiki.js

ARG BASE=jsz-clang
FROM $BASE

ARG REPO=https://github.com/saghul/txiki.js.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"
RUN git submodule update --init

RUN apt-get update -y && apt-get install -y libcurl4-openssl-dev texinfo libltdl-dev libffi-dev
RUN CFLAGS=-Wno-stringop-overread \
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_EXTERNAL_FFI=1 && \
    ninja -C build
# ffi submodule build fails

ENV JS_BINARY=/src/build/tjs
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+.*' >jsz_version
CMD ${JS_BINARY}
