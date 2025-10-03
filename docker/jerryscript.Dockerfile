ARG BASE=jsz-gcc14
FROM $BASE

ARG REPO=https://github.com/jerryscript-project/jerryscript.git
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

# Builds with -Os by default. Add --build-type=Release for -O3, but ~70% larger binary.
RUN python tools/build.py --mem-heap=65536

ENV JS_BINARY=/src/build/bin/jerry
CMD ${JS_BINARY}
