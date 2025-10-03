ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://github.com/nginx/njs.git
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN apt-get update -y && apt-get install -y --no-install-recommends libpcre2-dev libedit-dev
RUN ./configure --cc-opt="-O3" --no-openssl --no-libxml2 --no-quickjs --no-zlib && make -j

ENV JS_BINARY=/src/build/njs
CMD ${JS_BINARY}
