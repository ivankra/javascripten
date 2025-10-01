ARG BASE=jszoo-rust
FROM $BASE

ARG REPO=https://github.com/trynova/nova.git
ARG REV=main

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN cargo build --release --bin nova_cli

# Usage: ${JS_BINARY} eval script.js
ENV JS_BINARY=/src/target/release/nova_cli
CMD ${JS_BINARY} repl
