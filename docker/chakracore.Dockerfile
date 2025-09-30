FROM javascripten-ubuntu:22.04

ARG JS_REPO=https://github.com/chakra-core/ChakraCore.git
ARG JS_REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$JS_REV" "$JS_REPO" .

ARG JS_VARIANT=

RUN apt-get update -y && apt-get install -y clang
RUN ./build.sh --ninja --static --no-icu --without-intl $([ $JS_VARIANT = jitless ] && echo --no-jit)

ENV JS_BINARY=/src/out/Release/ch
# No REPL
