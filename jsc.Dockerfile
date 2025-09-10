# JavaScript engine of Safari/WebKit.
#
# URL:      https://trac.webkit.org/wiki/JavaScriptCore
# Standard: ESnext
# Tech:     register VM, 3-tier JIT, YARR
# Language: C++
# License:  LGPL-2.1 (but most of newer Apple's code under BSD)
# Org:      Apple
# LOC:      770374 (cloc --not_match_d="(?i)(test)" Source/JavaScriptCore)
#
# Timeline: 2001-
#   * 2001: KHTML/KJS forked by Apple (~37k LOC)
#     * Tree-walking interpreter
#     * PCRE-based regex engine ("JSCRE")
#   * 2008/06: SquirrelFish (predecessor to LLint)
#     * Direct-threaded register-based VM interpreter
#     * https://webkit.org/blog/189/announcing-squirrelfish/
#   * 2008/09: SquirrelFish Extreme/Nitro (now Baseline JIT)
#     * Context-threaded JIT (later template JIT), PIC => ~2x speedup
#     * WREC: new bytecode-based regex engine.
#     * https://webkit.org/blog/214/introducing-squirrelfish-extreme/
#     * https://github.com/WebKit/WebKit/commit/9b948e40c37ad6b4402d737f1a7639889e23c597
#   * 2009: YARR regex engine (interpreter, later template JIT)
#   * 2011: DFG JIT (Data Flow Graph)
#     * Fast optimizing JIT engine, SSA-based IR, compiles from bytecode
#     * Speculative optimizations with runtime type checks and deopts to interpreter/baseline
#     * ~2x speedup over LLint+Baseline
#     * https://trac.webkit.org/changeset/94559/webkit
#     * https://webkit.org/blog/10308/speculation-in-javascriptcore/
#   * 2014: FTL JIT (Fourth Tier LLVM / Faster Than Light)
#     * Advanced optimizing JIT engine, LLVM-based
#     * https://webkit.org/blog/3362/introducing-the-webkit-ftl-jit/
#     * https://blog.llvm.org/2014/07/ftl-webkits-llvm-based-jit.html
#   * 2016: FTL switched to a new in-house B3 backend from LLVM
#     * https://webkit.org/blog/5852/introducing-the-b3-jit-compiler/
#     * B3 also used for WebAssembly.
#   * 2017: WebAssembly
#     * BBQ (baseline) and OMG (optimizing) JIT tiers
#     * https://webkit.org/blog/7691/webassembly/
#
# VM (LLint):
#   * Register-based indirect-threaded VM, 3-arg binary ops
#   * https://webkit.org/blog/9329/a-new-bytecode-format-for-javascriptcore/
#   * Opcodes: https://github.com/WebKit/WebKit/blob/main/Source/JavaScriptCore/bytecode/BytecodeList.rb
#   * Ops implemented in "offlineasm" macroassembler, a Ruby-based DSL
#     * https://github.com/WebKit/WebKit/blob/main/Source/JavaScriptCore/llint/LowLevelInterpreter.asm
#     * https://github.com/WebKit/WebKit/tree/main/Source/JavaScriptCore/offlineasm
#     * cloop: offlineasm backend emitting portable C++

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/WebKit/WebKit.git
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone --depth=1 --branch="$JS_COMMIT" "$JS_REPO" .

RUN apt-get update -y && apt-get install -y libicu-dev clang
ENV CC=/usr/bin/clang CXX=/usr/bin/clang++

RUN Tools/Scripts/build-webkit \
      --jsc-only \
      --release \
      --cmakeargs="-DENABLE_STATIC_JSC=ON -DUSE_THIN_ARCHIVES=OFF"

ENV JS_BINARY=/work/WebKitBuild/JSCOnly/Release/bin/jsc
CMD ${JS_BINARY}
