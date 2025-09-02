# V8/libuv-based runtime.
#
# URL: https://github.com/nodejs/node

FROM javascripten-sh

# Precompiled release
ENV JS_BINARY=/opt/node/bin/node
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+.*' >version
CMD ${JS_BINARY}
