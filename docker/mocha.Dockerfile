FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/doodlewind/mocha1995
ARG JS_REV=main

WORKDIR /src
RUN git clone "$JS_REPO" . && git checkout "$JS_REV"

# Workaround for a crash in PR_cnvtf/PR_dtoa on arm64
RUN sed -i -e 's/PR_cnvtf(buf, sizeof buf, 20, fval);/snprintf(buf, sizeof(buf), "%.16g", fval);/' src/mo_num.c

RUN sed -i -e 's/CC=clang/CC="clang -O3"/' build.sh && bash -c 'source ./build.sh && compile_native'

ENV JS_BINARY=/src/out/mo_shell
CMD ${JS_BINARY}
