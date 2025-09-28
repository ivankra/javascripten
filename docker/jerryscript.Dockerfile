FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/jerryscript-project/jerryscript.git
ARG JS_REV=master

WORKDIR /src
RUN git clone "$JS_REPO" . && git checkout "$JS_REV"

# Builds with -Os by default. Add --build-type=Release for -O3, but ~70% larger binary.
RUN python tools/build.py --mem-heap=65536

ENV JS_BINARY=/src/build/bin/jerry
CMD ${JS_BINARY}
