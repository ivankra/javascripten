# castl

JavaScript to Lua compiler with runtime library.

* Repository: https://github.com/PaulBernier/castl.git <img src="https://img.shields.io/github/stars/PaulBernier/castl?label=&style=flat-square" /><img src="https://img.shields.io/github/last-commit/PaulBernier/castl?label=&style=flat-square" />
* LOC:        6366 (`cloc --not_match_d="(test|jscompile)" lua *.js`)
* Language:   Lua, JavaScript
* License:    LGPL-3.0-or-later
* Standard:   ES5 (partial, some ES6 through babel)
* Type:       compiler to Lua (targets unmodified Lua 5.2 / LuaJIT)
* Years:      2014-2017
* Parser:     Esprima / Acorn
* JIT:        via LuaJIT
* Regex:      PCRE2

Supports eval() through Lua-transpiled Castl/Esprima.

See also [Tessel Colony](tessel-colony.md).
