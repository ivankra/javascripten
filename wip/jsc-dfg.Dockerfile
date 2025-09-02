# JavaScriptCore build with Baseline/DFG JIT tiers.
#
# Running with only Baseline JIT: ./jsc --useDFGJIT=false

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/WebKit/WebKit.git
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone --depth=1 --branch="$JS_COMMIT" "$JS_REPO" .

RUN apt-get update -y && apt-get install -y libicu-dev clang
ENV CC=/usr/bin/clang CXX=/usr/bin/clang++

RUN Tools/Scripts/build-webkit \
      --no-ftl-jit \
      --no-webassembly \
      --jsc-only \
      --release \
      --cmakeargs="-DENABLE_STATIC_JSC=ON -DUSE_THIN_ARCHIVES=OFF"

ENV JS_BINARY=/work/WebKitBuild/JSCOnly/Release/bin/jsc
CMD ${JS_BINARY}
