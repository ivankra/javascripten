# iv / lv5

JIT-enabled ES5 engine in C++.

* Repository: https://github.com/Constellation/iv.git <img src="https://img.shields.io/github/stars/Constellation/iv?label=&style=flat-square" alt="GitHub stars" title="GitHub stars"><img src="https://img.shields.io/github/last-commit/Constellation/iv?label=&style=flat-square" alt="Last commit" title="Last commit">
* LOC:        69771 (`cloc --not_match_d="(?i)(test|third_party)" iv`)
* Language:   C++
* License:    BSD-2-Clause
* Standard:   ES5
* Years:      2009-2015
* Runtime:    register-based VM, PIC
* JIT:        context-threaded/method JIT, x64

## Components

  * iv/lv5/railgun: bytecode compiler
  * iv/lv5/railgun/vm.h: direct-threaded register-based VM, 3-args binary ops
  * iv/lv5/breaker: JIT compiler
  * iv/aero: regex engine with x64 JIT
