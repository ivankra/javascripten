# JavaScriptCore-based JS/TS runtime written in Zig.
#
# URL: https://github.com/oven-sh/bun

FROM javascripten-sh

# Precompiled release from `npm install bun`
ENV JS_BINARY=/opt/node/bin/bun
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+.*' >version
CMD ${JS_BINARY} repl
