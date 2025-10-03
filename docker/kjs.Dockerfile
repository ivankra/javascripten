ARG BASE=jsz-gcc
FROM $BASE

WORKDIR /src/ecm
RUN git clone --depth=1 https://github.com/KDE/extra-cmake-modules.git .
RUN cmake -B build -S . -G Ninja && cmake --build build && cmake --install build

RUN apt-get update -y && apt-get install -y --no-install-recommends qtbase5-dev

ARG REPO=https://github.com/KDE/kjs.git
ARG REV=kf5

WORKDIR /src/kjs
RUN git clone "$REPO" . && git checkout "$REV"

RUN export CFLAGS="-O3" CXXFLAGS="-O3" && \
    # Increase memory limit for Splay benchmark \
    sed -i -e 's/KJS_MEM_LIMIT 500000/KJS_MEM_LIMIT 2000000/' src/kjs/collector.h && \
    # Depends on ancient PCRE - disabled \
    cmake -B build -S . -G Ninja -DKJS_FORCE_DISABLE_PCRE=true -DBUILD_SHARED_LIBS=OFF && \
    cmake --build build

ENV JS_BINARY=/src/kjs/build/bin/kjs5
RUN ${JS_BINARY} --version | egrep -o '[0-9.]+' >jsz_version
CMD ${JS_BINARY}
