ARG BASE=jsz-gcc14
FROM $BASE

ARG REPO=https://github.com/facebook/hermes.git
ARG REV=main

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

# https://github.com/facebook/hermes/blob/main/doc/BuildingAndRunning.md
RUN apt-get update -y && apt-get install -y libicu-dev libreadline-dev
RUN cmake -S . -B build_release -G Ninja -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build_release

ENV JS_BINARY=/src/build_release/bin/hermes
RUN ${JS_BINARY} -version | grep Hermes.release | egrep -o [0-9.]+ >jsz_version
CMD ${JS_BINARY} -O

# Ahead-of-time compiler to bytecode engine.
# Run with -O (enable expensive optimization) for fair comparison.
