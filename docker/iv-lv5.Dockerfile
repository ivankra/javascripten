ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/Constellation/iv.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN apt-get update -y && apt-get install -y --no-install-recommends libgc-dev subversion

ARG VARIANT=

# Some bug on arm64 with gc causing infinite init loop, call LabelTable() singleton early.
RUN sed -iEe 's/iv::lv5::railgun::ExecuteInGlobal/iv::lv5::railgun::VM::LabelTable(); iv::lv5::railgun::ExecuteInGlobal/' iv/lv5/main.cc

# Builds with -O3
RUN export CXXFLAGS="-Wno-implicit-fallthrough -Wno-deprecated-copy -Wno-deprecated -Wl,--allow-multiple-definition" && \
    cmake -H. -Brelease -DCMAKE_BUILD_TYPE=Release $([ "$VARIANT" = jitless ] && echo "-DJIT=OFF") && \
    make -C release lv5 -j

ENV JS_BINARY=/src/release/iv/lv5/lv5
RUN if ${JS_BINARY} -v | grep -q "JIT..off"; then echo "" >jsz_jit; fi
CMD ${JS_BINARY}
