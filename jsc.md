# JavaScriptCore

* Summary:    JavaScript engine of Safari/WebKit.
* URL:        https://trac.webkit.org/wiki/JavaScriptCore
* Repository: https://github.com/WebKit/WebKit.git
* LOC:        770374 (`cloc --not_match_d="(?i)(test)" Source/JavaScriptCore`)
* Language:   C++
* License:    LGPL-2.0-only
  * LGPL-2.0-only: default / top-level
  * LGPL-2.0-or-later: most of original KJS code
  * BSD-2-Clause / BSD-3-Clause: most of Apple's contributions
* Org:        Apple
* Regex:      YARR
* Standard:   ESnext
* Tech:       register VM, 3-tier JIT
* Years:      2001-

## History

* 2001: KHTML/[KJS](kjs.md) forked by Apple (~37k LOC)
  * Tree-walking interpreter
  * PCRE-based regex engine ("JSCRE")
* 2008/06: SquirrelFish (predecessor to LLint)
  * Direct-threaded register-based VM interpreter
  * https://webkit.org/blog/189/announcing-squirrelfish/
* 2008/09: SquirrelFish Extreme/Nitro (now Baseline JIT)
  * Context-threaded JIT (later template JIT), PIC => ~2x speedup
  * WREC: new bytecode-based regex engine.
  * https://webkit.org/blog/214/introducing-squirrelfish-extreme/
  * https://github.com/WebKit/WebKit/commit/9b948e40c37ad6b4402d737f1a7639889e23c597
* 2009: YARR regex engine (interpreter, later template JIT)
* 2011: DFG JIT (Data Flow Graph)
  * Fast optimizing JIT engine, SSA-based IR, compiles from bytecode
  * Speculative optimizations with runtime type checks and deopts to interpreter/baseline
  * ~2x speedup over LLint+Baseline
  * https://trac.webkit.org/changeset/94559/webkit
  * https://webkit.org/blog/10308/speculation-in-javascriptcore/
* 2014: FTL JIT (Fourth Tier LLVM / Faster Than Light)
  * Advanced optimizing JIT engine, LLVM-based
  * https://webkit.org/blog/3362/introducing-the-webkit-ftl-jit/
  * https://blog.llvm.org/2014/07/ftl-webkits-llvm-based-jit.html
* 2016: FTL switched to a new in-house B3 backend from LLVM
  * https://webkit.org/blog/5852/introducing-the-b3-jit-compiler/
  * B3 also used for WebAssembly.
* 2017: WebAssembly
  * BBQ (baseline) and OMG (optimizing) JIT tiers
  * https://webkit.org/blog/7691/webassembly/

## VM (LLint)

* Register-based indirect-threaded VM, 3-arg binary ops
* https://webkit.org/blog/9329/a-new-bytecode-format-for-javascriptcore/
* Opcodes: https://github.com/WebKit/WebKit/blob/main/Source/JavaScriptCore/bytecode/BytecodeList.rb
* Ops implemented in "offlineasm" macroassembler, a Ruby-based DSL
  * https://github.com/WebKit/WebKit/blob/main/Source/JavaScriptCore/llint/LowLevelInterpreter.asm
  * https://github.com/WebKit/WebKit/tree/main/Source/JavaScriptCore/offlineasm
  * cloop: offlineasm backend emitting portable C++

## Users

* Safari and WebKit-based browsers (GNOME Web etc)
* The only JIT-enabled engine allowed by Apple on iOS
* [bun](https://github.com/oven-sh/bun): JavaScript/TypeScript runtime written in Zig.
