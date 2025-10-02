# Ancient Rust codebase. Only builds on x64.

ARG BASE=jszoo-rust
FROM $BASE

ARG REPO=https://github.com/Starlight-JS/starlight.git
ARG REV=dev

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN apt-get update -y && apt-get install -y --no-install-recommends rustup libssl-dev
#RUN rustup install 1.52.0 && rustup default 1.52.0
RUN rustup toolchain install nightly-2021-08-01 && rustup override set nightly-2021-08-01
RUN cargo build --release

ENV JS_BINARY=/src/target/release/sl
RUN mkdir -p /dist && rustc --version >/dist/json.rustc && git tag -d nightly
CMD ${JS_BINARY}
