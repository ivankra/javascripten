# Bun: JavaScriptCore-based runtime written in Zig.
# Supports TypeScript out of the box.
#
# URL: https://github.com/nodejs/node

FROM javascripten-sh

# Precompiled release: npm install bun
ENV JS_BINARY_LINK=/opt/node/bin/bun
CMD ${JS_BINARY_LINK} repl
