# Ancient Rust codebase. Only builds on x64.

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/Starlight-JS/starlight.git
ARG JS_COMMIT=dev

WORKDIR /src
RUN git clone "$JS_REPO" . && git checkout "$JS_REV"

RUN apt-get update -y && apt-get install -y --no-install-recommends rustup libssl-dev
#RUN rustup install 1.52.0 && rustup default 1.52.0
RUN rustup toolchain install nightly-2021-08-01 && rustup override set nightly-2021-08-01
RUN cargo build --release

ENV JS_BINARY=/src/target/release/sl
CMD ${JS_BINARY}
