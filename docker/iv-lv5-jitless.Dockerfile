# JIT-less build of iv-lv5.

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/Constellation/iv.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends libgc-dev subversion
# Some bug on arm64 with gc causing infinite init loop, call LabelTable() singleton early.
RUN sed -iEe 's/iv::lv5::railgun::ExecuteInGlobal/iv::lv5::railgun::VM::LabelTable(); iv::lv5::railgun::ExecuteInGlobal/' iv/lv5/main.cc
RUN export CXXFLAGS="-Wno-implicit-fallthrough -Wno-deprecated-copy -Wno-deprecated -Wl,--allow-multiple-definition" && \
    cmake -H. -Brelease -DCMAKE_BUILD_TYPE=Release -DJIT=OFF && \
    make -C release lv5 -j
# Verify that JIT is off: ./lv5 --version

ENV JS_BINARY=/work/release/iv/lv5/lv5
CMD ${JS_BINARY}
