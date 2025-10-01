ARG BASE=jszoo-gcc
FROM $BASE

ARG REPO=https://github.com/Samsung/escargot.git
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)
RUN git submodule update --init third_party

RUN apt-get update -y && apt-get install -y --no-install-recommends libicu-dev

# Note: builds with -O2 by default
RUN cmake -DESCARGOT_MODE=release -DESCARGOT_OUTPUT=shell -GNinja -Bbuild
RUN ninja -C build

ENV JS_BINARY=/src/build/escargot
CMD ${JS_BINARY}
