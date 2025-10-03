ARG BASE=jsz-ubuntu22
FROM $BASE

ARG REPO=https://github.com/chakra-core/ChakraCore.git
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

ARG VARIANT=

RUN apt-get update -y && apt-get install -y clang
RUN ./build.sh --ninja --static --no-icu --without-intl $([ "$VARIANT" = jitless ] && echo --no-jit)

ENV JS_BINARY=/src/out/Release/ch
# No REPL
