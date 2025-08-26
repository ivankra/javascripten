FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/Constellation/iv.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends libgc-dev subversion
RUN cmake -H. -Brelease -DCMAKE_BUILD_TYPE=Release && \
    make -C release lv5 -j

ENV JS_BINARY=/work/release/iv/lv5/lv5
CMD ${JS_BINARY}
