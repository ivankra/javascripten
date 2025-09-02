# V8/libuv-based runtime.
#
# URL: https://github.com/holepunchto/bare

FROM javascripten-sh

# Precompiled release: npm install bun
# /opt/node/lib/node_modules/bare/node_modules/bare-runtime-linux-arm64/bin/bare
ENV JS_BINARY=/opt/node/bin/bare
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+.*' >version
CMD ${JS_BINARY}
