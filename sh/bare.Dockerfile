# Bare: V8/libuv-based runtime.
#
# URL: https://github.com/holepunchto/bare

FROM javascripten-sh

# Precompiled release: npm install bun
ENV JS_BINARY_LINK=/opt/node/bin/bare
CMD ${JS_BINARY_LINK}
