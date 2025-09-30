# GraalJS

High-performance JavaScript engine for GraalVM.

* URL:        https://www.graalvm.org/javascript/
* Repository: https://github.com/oracle/graaljs.git <img src="https://img.shields.io/github/stars/oracle/graaljs?label=&style=flat-square" alt="Stars"><img src="https://img.shields.io/github/last-commit/oracle/graaljs?label=&style=flat-square" alt="Last commit">
* LOC:        191606 (`cloc --not_match_d="(?i)(test)" graal-js/src`)
* Language:   Java
* License:    UPL-1.0 (Universal Permissive License 1.0)
* Org:        Oracle
* Standard:   ESnext
* Years:      2018-
* Tech:       JVM, Truffle framework
* JIT:        2-tier JIT (HotSpot/Graal)

## Tech

Truffle: framework for extending GraalVM with support for new languages by automatically deriving high-performance code from interpreters. Based on the idea of partial evaluation of interpreters (Futamura projection) - essentially, unrolling of interpreter's loop for a given input to it. Cons: compilation overhead.

Related: [weval](https://github.com/bytecodealliance/weval) ([blog](https://cfallin.org/blog/2024/08/28/weval/))
