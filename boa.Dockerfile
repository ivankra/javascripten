FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/boa-dev/boa.git
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

# Debian version is too old
#RUN apt-get update -y && apt-get install -y --no-install-recommends rustc cargo libssl-dev
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash /dev/stdin -y
RUN apt-get update -y && apt-get install -y --no-install-recommends libssl-dev
RUN PATH="/root/.cargo/bin:$PATH" cargo build --release --bin boa

ENV JS_BINARY=/work/target/release/boa
CMD ${JS_BINARY}
