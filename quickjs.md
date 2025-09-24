# QuickJS

* Summary:    Lightweight embeddable JavaScript engine by Fabrice Bellard and Charlie Gordon.
* URL:        https://bellard.org/quickjs/
* Repository: https://github.com/bellard/quickjs.git
* GC:         reference counting
* LOC:        73590 (`cloc *.c *.h`)
* Language:   C
* License:    MIT
* Parser:     recursive descent, directly emits bytecode
* Runtime:    stack-based VM (`JS_CallInternal()` at [quickjs.c:16850](https://github.com/bellard/quickjs/blob/master/quickjs.c#L16850))
* Standard:   ES2023
* Tech:       stack VM, hidden classes w/o PIC, refcounting GC
* Years:      2019-

## Users

* [Nginx](https://github.com/nginx/njs): uses QuickJS as an alternative to home-grown [njs](njs.md) engine
* [PDF.js](https://github.com/mozilla/pdf.js/tree/master/external/quickjs): uses QuickJS compiled to WASM for sandboxing JavaScript code in .pdf
* [javy](https://github.com/bytecodealliance/javy.git): JS to WASM toolchain in Rust
* [LLRT](https://github.com/awslabs/llrt): lightweight QuickJS/tokio-based runtime by Amazon
* [elsa](https://github.com/elsaland/elsa): minimal JavaScript/TypeScript runtime written in Go
