ARG BASE=jsz-gcc14
FROM $BASE

ARG TARBALL=https://archive.mozilla.org/pub/js/js185-1.0.0.tar.gz

WORKDIR /src
RUN wget "$TARBALL" && tar xf "$(basename "$TARBALL")"

RUN mv js-1.8.5/js ./ && cd js/src && \
    export CXXFLAGS="--std=gnu++03" && \
    export CFLAGS="--std=gnu99 -Wno-implicit-int -Wno-implicit-function-declaration" && \
    sed -i -e 's/ -DENABLE_ASSEMBLER=.*//' Makefile.in && \
    # bad script permissions \
    chmod a+rx build/* && \
    # python 2 fixups \
    sed -i -e 's/"import sys; sys.exit.*"/""/' configure && \
    sed -i -E -e 's/print "(.*)"/print("\1")/' imacro_asm.py && \
    ./configure --host="$(uname -m)-unknown-linux" --enable-static --enable-optimize="-g" --disable-warnings-as-errors --disable-tracerjit --disable-methodjit --disable-monoic --disable-polyic && \
    # buggy script \
    sed -i -e 's/CXX=.*/$*; exit $?/' build/hcpp && \
    true
