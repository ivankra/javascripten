FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/boa-dev/boa.git
ARG JS_COMMIT=v0.20

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends rustc cargo libssl-dev
RUN cargo build --release --bin boa

ENV JS_BINARY=/work/target/release/boa
CMD ${JS_BINARY}
