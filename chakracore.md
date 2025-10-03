# ChakraCore

JavaScript engine of Microsoft Edge Legacy.

* Repository: https://github.com/chakra-core/ChakraCore.git <img src="https://img.shields.io/github/stars/chakra-core/ChakraCore?label=&style=flat-square" alt="GitHub stars" title="GitHub stars"><img src="https://img.shields.io/github/last-commit/chakra-core/ChakraCore?label=&style=flat-square" alt="Last commit" title="Last commit">
* LOC:        779986 (`cloc --fullpath --not_match_f="(?i)(test)" lib pal`)
* Language:   C++
* License:    MIT
* Note:       Doesn't support Linux arm64.
* Org:        Microsoft
* Standard:   ES2019
* Years:      2015-2021
* Runtime:    register-based VM, deferred compilation
* JIT:        2-tier JIT

## History

Originally kept the same name as the predecessor - IE9-11's [Chakra](chakra.md) engine (jscript9.dll).
Sometimes referred to as the new Chakra engine, Chakra Edge or chakra.dll.

Open-sourced in 2016 under the name ChakraCore.

Abandoned by Microsoft in 2021.

## Standard

* ES2020: BigInt implemented but disabled by default. No optional chaining.
