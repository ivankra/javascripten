FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/Samsung/escargot.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"
RUN git submodule update --init third_party

RUN apt-get update -y && apt-get install -y --no-install-recommends autoconf automake cmake libtool libicu-dev ninja-build pkg-config
RUN cmake -DESCARGOT_MODE=release -DESCARGOT_OUTPUT=shell -GNinja -Bbuild
RUN ninja -C build

ENV JS_BINARY=/work/build/escargot
CMD ${JS_BINARY}
