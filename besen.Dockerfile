# JIT-enabled ES5 engine written in Object Pascal.
#
# URL:      https://github.com/BeRo1985/besen
# Standard: ES5
# Tech:     register VM, context-threaded JIT (x86/x64), PIC
# Language: Pascal
# License:  LGPL-2.1 (with static linking exception)
# LOC:      57192 (cloc src)
# Timeline: 2009-2020

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/BeRo1985/besen.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends fpc
RUN fpc -O3 -Mdelphi src/BESENShell.lpr

# Use load() ro run a script.
# echo "load('/bench/navier-stokes.js')" | ./src/BESENShell | head
ENV JS_BINARY=/work/src/BESENShell
CMD ${JS_BINARY}
