# Deno: V8-based runtime, written in Rust.
# Using Rust's tokio instead of libuv.
# Supports TypeScript out of the box.
#
# URL: https://github.com/denoland/deno.git

FROM javascripten-sh

# Precompiled release: npm install deno
ENV JS_BINARY_LINK=/opt/node/bin/deno
CMD ${JS_BINARY_LINK}
