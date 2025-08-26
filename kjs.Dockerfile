FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/KDE/kjs.git
ARG JS_COMMIT=kf5

WORKDIR /work/ecm
RUN git clone --depth=1 https://github.com/KDE/extra-cmake-modules.git .
RUN cmake -B build -S . -G Ninja && cmake --build build && cmake --install build

RUN apt-get update -y && apt-get install -y qtbase5-dev

WORKDIR /work/kjs
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"
RUN cmake -B build -S . -G Ninja -DKJS_FORCE_DISABLE_PCRE=true -DBUILD_SHARED_LIBS=OFF && \
    cmake --build build

ENV JS_BINARY=/work/kjs/build/bin/kjs5
CMD ${JS_BINARY}
