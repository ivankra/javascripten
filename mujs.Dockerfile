# Embeddable JavaScript engine from MuPDF.
#
# URL:      https://codeberg.org/ccxvii/mujs
# Standard: ES5
# Tech:     stack VM
# Language: C
# License:  ISC
# LOC:      18490 (cloc *.c *.h)
# Timeline: 2013-

FROM javascripten-debian:stable

# https://github.com/ccxvii/mujs
ARG JS_REPO=https://codeberg.org/ccxvii/mujs.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends libreadline-dev
RUN make -j release  # by default builds with -O3

ENV JS_BINARY=/work/build/release/mujs
CMD ${JS_BINARY}
