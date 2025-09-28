FROM javascripten-debian:stable

# https://github.com/ccxvii/mujs
ARG JS_REPO=https://codeberg.org/ccxvii/mujs.git
ARG JS_REV=master

WORKDIR /src
RUN git clone "$JS_REPO" . && git checkout "$JS_REV"

RUN apt-get update -y && apt-get install -y --no-install-recommends libreadline-dev
RUN make -j release  # by default builds with -O3

ENV JS_BINARY=/src/build/release/mujs
CMD ${JS_BINARY}
