ARG BASE=jszoo-gcc
FROM $BASE

ARG REPO=https://codeberg.org/ccxvii/mujs.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN apt-get update -y && apt-get install -y --no-install-recommends libreadline-dev
RUN make -j release  # by default builds with -O3

ENV JS_BINARY=/src/build/release/mujs
CMD ${JS_BINARY}
