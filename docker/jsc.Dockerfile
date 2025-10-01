ARG BASE=jszoo-clang
FROM $BASE

ARG REPO=https://github.com/WebKit/WebKit.git
ARG REV=main

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN apt-get update -y && apt-get install -y libicu-dev

ARG VARIANT=

RUN export CXXFLAGS="-Wno-error" && \
    Tools/Scripts/build-webkit \
      $([ "$VARIANT" = dfg      ] && echo --no-ftl-jit --no-webassembly) \
      $([ "$VARIANT" = baseline ] && echo --no-ftl-jit --no-dfg-jit --no-webassembly) \
      $([ "$VARIANT" = jitless  ] && echo --no-jit --no-webassembly) \
      # LLint/offlineasm's CLoop backend: opcodes implemented in portable, \
      # but machine-generated C++, rather than assembly, ~20% slower \
      $([ "$VARIANT" = cloop    ] && echo --no-jit --no-webassembly --cloop --no-sampling-profiler) \
      --jsc-only \
      --release \
      --cmakeargs="-DENABLE_STATIC_JSC=ON -DUSE_THIN_ARCHIVES=OFF -DDEVELOPER_MODE_FATAL_WARNINGS=OFF"

ENV JS_BINARY=/src/WebKitBuild/JSCOnly/Release/bin/jsc
RUN curl "https://commits.webkit.org/$(git rev-parse HEAD)/json" 2>&1 | sed -Ene 's/.*"identifier": "([^"]+)".*/\1/p' >json.version
CMD ${JS_BINARY}
