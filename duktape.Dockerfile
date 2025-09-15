FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/svaarala/duktape.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends nodejs npm
RUN sed -i -e 's/ -Os / -O2 /' Makefile  # -Os by default
RUN make -j all

ENV JS_BINARY=/work/build/duk
CMD ${JS_BINARY}
