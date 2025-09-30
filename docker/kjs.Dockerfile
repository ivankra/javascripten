FROM javascripten-debian:stable

WORKDIR /src/ecm
RUN git clone --depth=1 https://github.com/KDE/extra-cmake-modules.git .
RUN cmake -B build -S . -G Ninja && cmake --build build && cmake --install build

RUN apt-get update -y && apt-get install -y qtbase5-dev

ARG JS_REPO=https://github.com/KDE/kjs.git
ARG JS_REV=kf5

WORKDIR /src/kjs
RUN git clone "$JS_REPO" . && git checkout "$JS_REV"

RUN export CXXFLAGS="-O2" && \
    # Increase memory limit for Splay benchmark \
    sed -i -e 's/KJS_MEM_LIMIT 500000/KJS_MEM_LIMIT 2000000/' src/kjs/collector.h && \
    # Depends on ancient PCRE - disabled \
    cmake -B build -S . -G Ninja -DKJS_FORCE_DISABLE_PCRE=true -DBUILD_SHARED_LIBS=OFF && \
    cmake --build build

ENV JS_BINARY=/src/kjs/build/bin/kjs5
RUN ${JS_BINARY} --version | egrep -o '[0-9.]+' >json.version
CMD ${JS_BINARY}
