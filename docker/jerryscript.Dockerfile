FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/jerryscript-project/jerryscript.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN python tools/build.py --mem-heap=10240

ENV JS_BINARY=/work/build/bin/jerry
CMD ${JS_BINARY}
