# iv / lv5

JIT-enabled ES5 engine in C++.

* Repository: https://github.com/Constellation/iv.git
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
