ARG BASE=jsz-debian
FROM $BASE

ARG REPO=https://codeberg.org/kiesel-js/kiesel.git
ARG REV=main

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

ARG ZIG_VER=0.15.1

RUN apt-get update -y && apt-get install -y --no-install-recommends cargo
RUN cd /opt && wget -O zig.tar.xz "https://ziglang.org/download/${ZIG_VER}/zig-$(uname -m)-linux-${ZIG_VER}.tar.xz" && \
    tar vxf zig.tar.xz && rm -f zig.tar.xz && ln -s /opt/zig-*/zig /usr/bin/zig

RUN zig build --release=fast

ENV JS_BINARY=/src/zig-out/bin/kiesel
RUN ${JS_BINARY} --version | grep -i kiesel | grep -o '[0-9].*' >jsz_version
CMD ${JS_BINARY}
