# goja

* Summary:    JavaScript engine in pure Go.
* Repository: https://github.com/dop251/goja.git
* LOC:        46141 (`cloc --fullpath --not_match_f="(?i)(test)" --exclude-lang=Markdown,YAML .`)
* Language:   Go
* License:    MIT
* Standard:   ES6 (partial)
* Tech:       stack VM
* Parser:     recursive descent
  * Fork of [otto](otto.md)'s parser from 2016.
  * Code: https://github.com/dop251/goja/tree/master/parser
  * LOC: 4285 (`cloc --fullpath --not_match_f="(?i)(test)" --exclude-lang=Markdown parser`)
* Years:      2016-

## Users

* [Geth](https://github.com/ethereum/go-ethereum) - Ethereum's Go implementation
* [Grafana](https://github.com/grafana/sobek/) - maintains own fork "Sobek"
