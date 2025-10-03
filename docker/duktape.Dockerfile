ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/svaarala/duktape.git
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN apt-get update -y && apt-get install -y --no-install-recommends nodejs npm bc

RUN sed -i -e 's/ -Os / -O3 /' Makefile  # -Os by default
RUN make -j all

ENV JS_BINARY=/src/build/duk
CMD ${JS_BINARY}
