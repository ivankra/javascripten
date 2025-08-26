# Node: V8-based runtime.
#
# URL: https://github.com/nodejs/node

FROM javascripten-sh

# Precompiled release
ENV JS_BINARY=/opt/node/bin/node
CMD ${JS_BINARY}
