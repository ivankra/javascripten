# V8/tokio-based JS/TS runtime written in Rust.
#
# URL: https://github.com/denoland/deno

FROM javascripten-sh

# Precompiled release from `npm install deno`
#ENV JS_BINARY=/opt/node/bin/deno
ENV JS_BINARY=/opt/node/lib/node_modules/deno/deno
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+.*' >version
CMD ${JS_BINARY}
