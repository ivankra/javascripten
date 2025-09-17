FROM javascripten-debian:stable

ARG JS_REPO=https://codeberg.org/kiesel-js/kiesel.git
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends cargo
RUN wget -O /opt/zig.tar.xz "https://ziglang.org/download/0.14.1/zig-$(uname -m)-linux-0.14.1.tar.xz" && \
    cd /opt && tar vxf zig.tar.xz && ln -s /opt/zig-*/zig /usr/bin/zig
RUN zig build --release=fast

ENV JS_BINARY=/work/zig-out/bin/kiesel
RUN ${JS_BINARY} --version | grep kiesel | grep -o '[0-9].*' >version
CMD ${JS_BINARY}
