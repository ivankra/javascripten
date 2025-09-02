# Lightweight engine for microcontrollers.
#
# URL:      https://github.com/Moddable-OpenSource/moddable/
# Standard: ESnext
# Tech:     stack VM
# Language: C
# License:  LGPL-3.0+, Apache-2.0
# LOC:      129071 (cloc xs)
# Timeline: 2016-

# https://github.com/Moddable-OpenSource/moddable/blob/public/documentation/Moddable%20SDK%20-%20Getting%20Started.md#lin-instructions
FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/Moddable-OpenSource/moddable.git
ARG JS_COMMIT=public

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends libncurses-dev
RUN cd xs/makefiles/lin && MODDABLE=/work make -j

ENV JS_BINARY=/work/build/bin/lin/release/xst
# No REPL
