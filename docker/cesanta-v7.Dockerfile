ARG BASE=jsz-gcc
FROM $BASE

# HEAD is broken

ARG REPO=https://github.com/cesanta/v7.git
ARG REV=ce5212ae42dfd93247c56fbc233f65367e9def27

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN gcc -o v7 -O3 -DV7_LARGE_AST -DV7_EXE -DCS_ENABLE_UTF8 v7.c -lm

ENV JS_BINARY=/src/v7
# No REPL
