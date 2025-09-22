# GraalJS

* Summary:    High-performance JavaScript engine for GraalVM.
* URL:        https://www.graalvm.org/javascript/
* Repository: https://github.com/oracle/graaljs.git
* LOC:        191606 (`cloc --not_match_d="(?i)(test)" graal-js/src`)
* Language:   Java
* License:    UPL-1.0
* Org:        Oracle
* Standard:   ESnext
* Tech:       JVM, 2-tier JIT (HotSpot/Graal), Truffle framework
* Years:      2018-

## Tech

Truffle: framework for extending GraalVM with support for new languages by automatically deriving high-performance code from interpreters. Based on the idea of partial evaluation of interpreters (Futamura projection) - essentially, unrolling of interpreter's loop for a given input to it. Cons: compilation overhead.

Related: [weval](https://github.com/bytecodealliance/weval) ([blog](https://cfallin.org/blog/2024/08/28/weval/))
