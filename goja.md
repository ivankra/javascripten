# goja

JavaScript engine in pure Go.

* Repository: https://github.com/dop251/goja.git
* LOC:        46141 (`cloc --fullpath --not_match_f="(?i)(test)" --exclude-lang=Markdown,YAML .`)
* Language:   Go
* License:    MIT
* Standard:   ES6 (partial)
* Years:      2016-
* Parser:     recursive descent (fork of otto's parser, [code](https://github.com/dop251/goja/tree/master/parser/), LOC: 4285)
* Runtime:    stack-based VM

## Users

* [Geth](https://github.com/ethereum/go-ethereum) - Ethereum's Go implementation
* [Grafana](https://github.com/grafana/sobek/) - maintains own fork "Sobek"
