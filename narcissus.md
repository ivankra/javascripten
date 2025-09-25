# Narcissus

Metacircular JavaScript interpreter, was used for prototyping new language features in ES6.

* Repository: https://github.com/mozilla/narcissus.git <img src="https://img.shields.io/github/stars/mozilla/narcissus?label=&style=flat-square" /><img src="https://img.shields.io/github/last-commit/mozilla/narcissus?label=&style=flat-square" />
* LOC:        6308 (`cloc lib`)
* Language:   JavaScript
* License:    MPL-1.1-or-later OR GPL-2.0-or-later OR LGPL-2.1-or-later
* Org:        Mozilla
* Standard:   ES5
* Years:      2007-2012

> Narcissus is a meta-circular JavaScript interpreter with a very
> direct representation of values: primitives are self-representing,
> objects are represented as objects (with their properties accessible via
> usual property access), and functions are represented as functions. The
> interpreter is designed this way to allow existing JavaScript functions
> and objects (such as the standard libraries) to interface directly
> with Narcissus code without following any special protocol or requiring
> wrapping and unwrapping.
