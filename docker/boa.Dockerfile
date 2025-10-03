ARG BASE=jsz-rust
FROM $BASE

ARG REPO=https://github.com/boa-dev/boa.git
ARG REV=main

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN apt-get update -y && apt-get install -y --no-install-recommends libssl-dev

RUN cargo build --release --bin boa

ENV JS_BINARY=/src/target/release/boa
CMD ${JS_BINARY}
