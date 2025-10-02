# QuickJS

Lightweight embeddable JavaScript engine by Fabrice Bellard and Charlie Gordon.

* URL:        https://bellard.org/quickjs/
* Repository: https://github.com/bellard/quickjs.git <img src="https://img.shields.io/github/stars/bellard/quickjs?label=&style=flat-square" alt="GitHub stars" title="GitHub stars"><img src="https://img.shields.io/github/last-commit/bellard/quickjs?label=&style=flat-square" alt="Last commit" title="Last commit">
* LOC:        73590 (`cloc *.c *.h`)
* Language:   C
* License:    MIT
* Standard:   ES2023
* Years:      2019-
* Parser:     recursive descent, directly emits bytecode
* Runtime:    stack-based VM, hidden classes
* VM:         `JS_CallInternal()` at [quickjs.c:16850](https://github.com/bellard/quickjs/blob/master/quickjs.c#L16850)
* GC:         reference counting

## Users

* [Nginx](https://github.com/nginx/njs): uses QuickJS as an alternative to home-grown [njs](njs.md) engine
* [PDF.js](https://github.com/mozilla/pdf.js/tree/master/external/quickjs): uses QuickJS compiled to WASM for sandboxing JavaScript code in .pdf
* [javy](https://github.com/bytecodealliance/javy.git): JS to WASM toolchain in Rust
* [LLRT](https://github.com/awslabs/llrt): lightweight QuickJS/tokio-based runtime by Amazon
* [elsa](https://github.com/elsaland/elsa): minimal JavaScript/TypeScript runtime written in Go
