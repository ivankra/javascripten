ARG BASE=jsz-golang
FROM $BASE

ARG REPO=https://gitlab.com/cznic/quickjs.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

# There's no shell binary in the project.
# Define and build a basic REPL shell / test runner.
RUN cat >main.go <<EOF
//go:build ignore
package main

import (
	"bufio"
	"fmt"
	"os"

	"modernc.org/quickjs"
)

func main() {
	vm, err := quickjs.NewVM()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create VM: %v\n", err)
		os.Exit(1)
	}
	defer vm.Close()

	vm.StdAddHelpers()  // print, console.log bindings

	if len(os.Args) > 1 {
		filename := os.Args[1]
		data, err := os.ReadFile(filename)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Failed to read file %s: %v\n", filename, err)
			os.Exit(1)
		}

		_, err = vm.Eval(string(data), quickjs.EvalGlobal)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	} else {
		scanner := bufio.NewScanner(os.Stdin)
		for {
			fmt.Print("> ")
			if !scanner.Scan() {
				break
			}

			result, err := vm.Eval(scanner.Text(), quickjs.EvalGlobal)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			} else if _, isUndefined := result.(quickjs.Undefined); !isUndefined {
				fmt.Println(result)
			}
		}

		if err := scanner.Err(); err != nil {
			fmt.Fprintf(os.Stderr, "Error reading input: %v\n", err)
			os.Exit(1)
		}
	}
}
EOF

RUN go build main.go

ENV JS_BINARY=/src/main
CMD ${JS_BINARY}
