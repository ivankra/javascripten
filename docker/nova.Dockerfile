FROM javascripten-debian:stable

# Unstable project...  b6b295cc 2025-07-06
ARG JS_REPO=https://github.com/trynova/nova.git
ARG JS_COMMIT=b6b295ccdebc8b7a4be22e77721cefb827af4359

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

# Latest rust needed
RUN sed -i -e 's/ stable-updates$/ stable-updates sid/' /etc/apt/sources.list.d/debian.sources
RUN apt-get update -y && apt-get install -y --no-install-recommends -t sid rustc cargo
RUN cargo build --release --bin nova_cli

# Usage: ${JS_BINARY} eval script.js
ENV JS_BINARY=/work/target/release/nova_cli
CMD ${JS_BINARY} repl
