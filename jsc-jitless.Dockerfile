# JIT-less build of JavaScriptCore.

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/WebKit/WebKit.git
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone --depth=1 --branch="$JS_COMMIT" "$JS_REPO" .

RUN apt-get update -y && apt-get install -y libicu-dev clang
ENV CC=/usr/bin/clang CXX=/usr/bin/clang++

RUN Tools/Scripts/build-webkit \
      --no-jit \
      --no-webassembly \
      --jsc-only \
      --release \
      --cmakeargs="-DENABLE_STATIC_JSC=ON -DUSE_THIN_ARCHIVES=OFF"

# Enable LLint/offlineasm's CLoop backend (opcodes implemented in portable,
# but machine-generated C++, rather than assembly), ~20% slower:
#     --cloop --no-sampling-profiler

ENV JS_BINARY=/work/WebKitBuild/JSCOnly/Release/bin/jsc
CMD ${JS_BINARY}
