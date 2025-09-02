# JavaScript interpreter for some microcontrollers.
# Awfully slow, no var/func hoisting.
#
# URL:      https://www.espruino.com/
# Standard: non-compliant
# Tech:     interprets from source
# Language: C
# License:  MPL-2.0
# LOC:      28352 (cloc src)
# Timeline: 2013-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/espruino/Espruino.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN sed -i -e 's/ -Os / -O2 /' Makefile  # -Os by default
RUN make -j RELEASE=1

ENV JS_BINARY=/work/bin/espruino
CMD ${JS_BINARY}
