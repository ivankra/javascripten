FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/espruino/Espruino.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN sed -i -e 's/ -Os / -O2 /' Makefile  # -Os by default
RUN make -j

ENV JS_BINARY=/work/bin/espruino
CMD ${JS_BINARY}
