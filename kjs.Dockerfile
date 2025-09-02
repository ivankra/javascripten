# Original JavaScript engine of KDE's Konqueror browser.
#
# URL:      https://invent.kde.org/frameworks/kjs
# Standard: ES5
# Tech:     tree-walker / register VM (2008)
# Language: C++
# License:  LGPL-2.1
# Org:      KDE
# LOC:      42352 (cloc src)
# Timeline: 1998-2024
#   * Forked by Apple in 2001.
#   * Most dead already by KDE 5 (2014), dropped from KDE 6 (2024)

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
