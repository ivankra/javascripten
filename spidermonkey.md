# SpiderMonkey

* Summary:    JavaScript engine of Firefox.
* URL:        https://spidermonkey.dev/
* Repository: https://github.com/mozilla-firefox/firefox.git
* LOC:        1028123 (`cloc --not_match_d="(?i)(test|octane)" js/src`)
* Language:   C++
* License:    MPL-2.0
* Org:        Mozilla
* Standard:   ESnext
* Tech:       stack VM, 2-tier JIT, Irregexp
* Years:      1996-

## History

  * 1996: Nescape Navigator 2.0
    * Traces history all the way back to the first browser with JavaScript.
  * 2008: TraceMonkey - tracing JIT compiler for hot loops
  * 2010: JägerMonkey - method JIT
    * https://hacks.mozilla.org/2010/03/improving-javascript-performance-with-jagermonkey/
  * 2012: IonMonkey - SSA-based optimizing compiler
  * 2013: Baseline JIT - method JIT
    * Inline caching, collects type information
    * https://blog.mozilla.org/javascript/2013/04/05/the-baseline-compiler-has-landed/
  * 2014: Irregexp engine from V8
    * https://hacks.mozilla.org/2020/06/a-new-regexp-engine-in-spidermonkey/
  * 2019: Baseline Interpreter
    * https://hacks.mozilla.org/2019/08/the-baseline-interpreter-a-faster-js-interpreter-in-firefox-70/
    * https://github.com/mozilla-firefox/firefox/blob/main/js/src/vm/Interpreter.cpp
    * https://github.com/mozilla-firefox/firefox/blob/main/js/src/vm/Opcodes.h
  * 2020: WarpMonkey
