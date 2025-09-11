FROM javascripten-ubuntu:22.04

ARG JS_REPO=https://github.com/chakra-core/ChakraCore.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone --depth=1 --branch="$JS_COMMIT" "$JS_REPO" .

RUN apt-get update -y && apt-get install -y clang
RUN ./build.sh --ninja --static --no-icu --without-intl

ENV JS_BINARY=/work/out/Release/ch
# No REPL


