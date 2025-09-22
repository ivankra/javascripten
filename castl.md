# castl

* Summary:    JavaScript to Lua compiler with runtime library.
* Repository: https://github.com/PaulBernier/castl.git
* LOC:        6366 (`cloc --not_match_d="(test|jscompile)" lua *.js`)
* Language:   Lua, JavaScript
* License:    LGPL-3.0-or-later
* Parser:     Esprima / Acorn
* Regex:      PCRE2
* Standard:   ES5 (partial)
  * ES6 through babel, built-in flag to call it
  * Supports eval() through Lua version of Castl/Esprima
* Tech:       compiler to Lua (unmodified Lua 5.2 / LuaJIT)
* Years:      2014-2017

See also [Tessel Colony](tessel-colony.md).
