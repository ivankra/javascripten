FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/Starlight-JS/starlight.git
ARG JS_COMMIT=dev

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends rustc cargo libssl-dev
RUN cargo build --release

ENV JS_BINARY=/work/target/release/starlight
CMD ${JS_BINARY}
