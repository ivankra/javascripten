# SpiderMonkey

JavaScript engine of Firefox.

* URL:        https://spidermonkey.dev/
* Repository: https://github.com/mozilla-firefox/firefox.git <img src="https://img.shields.io/github/stars/mozilla-firefox/firefox?label=&style=flat-square" alt="GitHub stars" title="GitHub stars"><img src="https://img.shields.io/github/last-commit/mozilla-firefox/firefox?label=&style=flat-square" alt="Last commit" title="Last commit">
* LOC:        1028123 (`cloc --not_match_d="(?i)(test|octane)" js/src`)
* Language:   C++
* License:    MPL-2.0
* Org:        Mozilla
* Standard:   ESnext
* Years:      1996-
* Runtime:    stack-based VM
* JIT:        2-tier JIT
* Regex:      Irregexp

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

## Users

* Firefox, Thunderbird and other Mozilla apps
* GNOME 3+, Cinnamon desktop environments
* [MongoDB](https://github.com/mongodb/mongo/tree/master/src/mongo/scripting), CouchDB, Riak
* [Acrobat Reader](https://opensource.adobe.com/dc-acrobat-sdk-docs/library/jsapiref/index.html) and other Adobe products: stuck on SpiderMonkey 1.8.5 fork ("AcroJS")
* Runtimes:
  * [WinterJS](https://github.com/wasmerio/winterjs): SpiderMonkey/hyper.rs-based runtime
  * [spiderfire](https://github.com/Redfire75369/spiderfire) runtime
