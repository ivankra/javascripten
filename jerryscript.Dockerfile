# Lightweight JavaScript engine for microcontrollers.
#
# URL:      https://jerryscript.net/
# Standard: ES2022 with some exceptions
# Tech:     stack VM
# Language: C
# License:  Apache-2.0
# Org:      Samsung
# LOC:      108762 (cloc jerry-*)
# Timeline: 2014-
# Note:     Built with --mem-heap=10240 (10MiB)

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/jerryscript-project/jerryscript.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN python tools/build.py --mem-heap=10240

ENV JS_BINARY=/work/build/bin/jerry
CMD ${JS_BINARY}
