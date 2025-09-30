# First ES5-compliant SpiderMonkey version, shipped in Firefox 4.0 (2011).
# Features TraceMonkey tracing JIT, JägerMonkey method JIT, PIC, YARR.
#
# Doesn't work on arm64, JIT doesn't support this target.

FROM javascripten-debian:stable

# JavaScript-C 1.8.5 2011-03-31
ARG TARBALL=https://archive.mozilla.org/pub/js/js185-1.0.0.tar.gz

WORKDIR /src
RUN wget "$TARBALL" && tar xf "$(basename "$TARBALL")"

RUN mv js-1.8.5/js ./ && cd js/src && \
    export CXXFLAGS="--std=gnu++03" && \
    export CFLAGS="--std=gnu99 -Wno-implicit-int -Wno-implicit-function-declaration" && \
    # bad script permissions \
    chmod a+rx build/* && \
    # python 2 fixups \
    sed -i -e 's/"import sys; sys.exit.*"/""/' configure && \
    sed -i -E -e 's/print "(.*)"/print("\1")/' imacro_asm.py && \
    ./configure --host="$(uname -m)-unknown-linux" --enable-static --enable-optimize="-O3" --disable-warnings-as-errors && \
    # buggy script \
    sed -i -e 's/CXX=.*/$CXX $*; exit $?/' build/hcpp && \
    make

ENV JS_BINARY=/src/js/src/shell/js
RUN ${JS_BINARY} --help 2>&1 | sed -Ene 's/JavaScript-C (1[.0-9]*) .*$/\1/p' >json.version && \
    ${JS_BINARY} --help 2>&1 | sed -Ene 's/JavaScript-C (1[.0-9]*) (.* )?([0-9]{4}-[-0-9]+)$/\3/p' >json.revision_date
CMD ${JS_BINARY}
