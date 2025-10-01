ARG BASE=jszoo-debian
FROM $BASE

ARG REPO=https://github.com/BeRo1985/besen.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN apt-get update -y && apt-get install -y --no-install-recommends fpc
RUN fpc -O3 -Mdelphi src/BESENShell.lpr

ENV JS_BINARY=/src/src/BESENShell
CMD ${JS_BINARY}

# Use load() to run a script.
# echo "load('/bench/navier-stokes.js')" | ./src/BESENShell | head
