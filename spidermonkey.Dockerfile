# JavaScript engine of Firefox.
#
# URL:      https://spidermonkey.dev/
# Standard: ESnext
# Tech:     stack VM, 2-tier JIT, Irregexp
# Language: C++
# License:  MPL-2.0
# Org:      Mozilla
# LOC:      1028123 (cloc --not_match_d="(?i)(test|octane)" js/src)
#
# Timeline: 1996-
#   * 1996: Nescape Navigator 2.0
#     * Traces history all the way back to the first browser with JavaScript.
#   * 2008: TraceMonkey - tracing JIT compiler for hot loops
#   * 2010: JägerMonkey - method JIT
#     * https://hacks.mozilla.org/2010/03/improving-javascript-performance-with-jagermonkey/
#   * 2012: IonMonkey - SSA-based optimizing compiler
#   * 2013: Baseline JIT - method JIT
#     * Inline caching, collects type information
#     * https://blog.mozilla.org/javascript/2013/04/05/the-baseline-compiler-has-landed/
#   * 2014: Irregexp engine from V8
#     * https://hacks.mozilla.org/2020/06/a-new-regexp-engine-in-spidermonkey/
#   * 2019: Baseline Interpreter
#     * https://hacks.mozilla.org/2019/08/the-baseline-interpreter-a-faster-js-interpreter-in-firefox-70/
#     * https://github.com/mozilla-firefox/firefox/blob/main/js/src/vm/Interpreter.cpp
#     * https://github.com/mozilla-firefox/firefox/blob/main/js/src/vm/Opcodes.h
#   * 2020: WarpMonkey
#
# GC: https://firefox-source-docs.mozilla.org/js/gc.html
#
# Build instructions: https://firefox-source-docs.mozilla.org/js/build.html
# Run './js/src/configure --help' for configure options.
# Full binary: 35.4M (stripped arm64)
# --with-system-icu => 18.2M
# --without-intl-api --disable-icu4x => 14.9M
# --without-intl-api --disable-icu4x --disable-jit => 12.7M

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/mozilla-firefox/firefox
ARG JS_COMMIT=release

WORKDIR /work
RUN git clone --branch="$JS_COMMIT" --depth=1 "$JS_REPO" .

RUN apt-get update -y && apt-get install -y libxml2 libz-dev libicu-dev python3-pip python3-psutil clang cargo rustc cbindgen

RUN { \
      echo "ac_add_options --enable-project=js"; \
      echo "ac_add_options --enable-jit"; \
      echo "ac_add_options --enable-optimize"; \
      echo "ac_add_options --enable-release"; \
      echo "ac_add_options --enable-strip"; \
      echo "ac_add_options --disable-debug"; \
      echo "ac_add_options --disable-debug-symbols"; \
      echo "ac_add_options --disable-tests"; \
      echo "ac_add_options --without-intl-api"; \
      echo "ac_add_options --disable-icu4x"; \
    } >MOZCONFIG
RUN MOZCONFIG=/work/MOZCONFIG ./mach build
RUN ln -s obj-*/ obj

ENV JS_BINARY=/work/obj/dist/bin/js
RUN ${JS_BINARY} -v | egrep -o [0-9.]+ >version
CMD ${JS_BINARY}
