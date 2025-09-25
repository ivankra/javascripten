# Mocha

The very first JavaScript engine that defined early JavaScript language (JS1.0/1.1), used in Netscape 2.0-3.0.

* GitHub:     https://github.com/doodlewind/mocha1995.git (ns302 version ported to modern toolchain) <img src="https://img.shields.io/github/stars/doodlewind/mocha1995?label=&style=flat-square" /><img src="https://img.shields.io/github/last-commit/doodlewind/mocha1995?label=&style=flat-square" />
* LOC:        13728 (ns302 version)
* Language:   C++
* License:    Proprietary
* Standard:   JS1.1 (≈ ES1)
* Years:      1995-1996
* Parser:     recursive descent, directly emits bytecode ([mo_parse.c](https://github.com/doodlewind/mocha1995/blob/main/src/mo_parse.c), 953 LOC)
* Runtime:    stack-based VM ([mocha.c](https://github.com/doodlewind/mocha1995/blob/main/src/mocha.c))
* GC:         reference counting

## History

* May 1995: prototyped during a 10-day sprint.
* Aug 1995: feature freeze for Netscape Navigator 2.0, constrained JS1.0 to feature set of what was working at that time, incomplete relative to envisioned language design.
* Sep 1995: Netscape Navigator 2.0b1 - first browser to support JavaScript (marketed as LiveScript at the time), JavaScript 1.0
* Dec 1995: Sun/Netscape press release announcing JavaScript
* Aug 1996: Netscape Navigator 3.0 came out - JavaScript 1.1 version, completed initial development of JavaScript.

## References

* Allen Wirfs-Brock and Brendan Eich. 2020. [JavaScript: the first 20 years](https://dl.acm.org/doi/pdf/10.1145/3386327). Proc. ACM Program. Lang. 4, HOPL, Article 77.
* [Netscape Communicator 3.0.2 Source Tree](https://archive.org/details/netscape-communicator-3-0-2-source) (archive.org)
