# Facebook's JavaScript engine optimized for running mobile React Native apps.
#
# URL:      https://hermesengine.dev/
# Standard: ES6 with some exceptions
# Tech:     register VM, optimizing AOT compiler, SSA IR, generational GC
# Language: C++
# License:  MIT
# Org:      Facebook
# LOC:      169845 (cloc include lib tools/hermes)
# Timeline: 2019-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/facebook/hermes.git
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone --depth=1 --branch="$JS_COMMIT" "$JS_REPO" .

# https://github.com/facebook/hermes/blob/main/doc/BuildingAndRunning.md
RUN apt-get update -y && apt-get install -y libicu-dev libreadline-dev
RUN cmake -S . -B build_release -G Ninja -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build_release

# Ahead-of-time compile to bytecode engine.
# Run with -O (enable expensive optimization) for fair comparison.
ENV JS_BINARY=/work/build_release/bin/hermes
RUN ${JS_BINARY} -version | grep Hermes.release | egrep -o [0-9.]+ >version
CMD ${JS_BINARY} -O
