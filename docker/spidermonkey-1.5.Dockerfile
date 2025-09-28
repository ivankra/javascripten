# First ES3-compliant SpiderMonkey version.
# Shipped in Netscape Navigator 6.0 (2000) and Firefox 1.0 (2004).
#
# Version/feature history:
# https://web.archive.org/web/20210420113930/https://developer.mozilla.org/en-US/docs/Archive/Web/JavaScript/New_in_JavaScript
#
# Other pre-C++/JIT versions from https://archive.mozilla.org/pub/js/
# should also work with this build script. 1.8.1+ (Firefox 3.5+) added JIT
# with a much more complicated and less portable build system - won't work.
#
# JavaScript-C 1.4 release 1 1998 10 31
# ARG TARBALL=https://archive.mozilla.org/pub/js/older-packages/js-1.4-1.tar.gz
# ARG TARBALL=https://archive.mozilla.org/pub/js/older-packages/js-1.4-2.tar.gz
# https://github.com/mozilla-firefox/firefox.git fc767ea7421a9322194cffbeaf0e83e4a4a3543c
#
# JavaScript-C 1.5 2004-09-24
# ARG TARBALL=https://archive.mozilla.org/pub/js/older-packages/js-1.5.tar.gz
#
# JavaScript-C 1.6 2006-11-19
# ARG TARBALL=https://archive.mozilla.org/pub/js/js-1.60.tar.gz
#
# JavaScript-C 1.7.0 2007-10-03
# ARG TARBALL=https://archive.mozilla.org/pub/js/js-1.7.0.tar.gz
#
# JavaScript-C 1.8.0 pre-release 1 2009-02-16
# ARG TARBALL=https://archive.mozilla.org/pub/js/js-1.8.0-rc1.tar.gz
#
# With some more work, JS1.3 from Netscape 4.0x might build.
# JavaScript-C 1.3 1998 06 30
# ARG TARBALL=https://ftp.mozilla.org/pub/mozilla/source/mozilla-19981008.tar.gz
# https://github.com/mozilla-firefox/firefox.git 5858e3255b42cdd854bc3fa597abb65c07707de6

FROM javascripten-debian:stable

ARG TARBALL=https://archive.mozilla.org/pub/js/older-packages/js-1.5.tar.gz

WORKDIR /src
RUN wget "$TARBALL" && tar xf "$(basename "$TARBALL")"

RUN if [ -d src ]; then ln -s . js; fi && \
    cd js/src && \
    # -fPIC: workaround for some linker errors \
    export CFLAGS="--std=c99 -Wno-implicit-function-declaration -fPIC -O3" && \
    # Make sure to use -O3 for BUILD_OPT=1 \
    sed -i -E -e 's/^((INTERP_)?OPTIMIZER) *= .*/\1 = -O3/' config.mk && \
    # Fix JS_STACK_GROWTH_DIRECTION misdetection at -O2 \
    sed -i -e 's/^static int StackGrowthDirection/static int __attribute__((noinline)) StackGrowthDirection/' jscpucfg.c && \
    make -f Makefile.ref BUILD_OPT=1

ENV JS_BINARY=/src/js/src/Linux_All_OPT.OBJ/js
RUN ${JS_BINARY} --help 2>&1 | sed -Ene 's/JavaScript-C (1[.0-9]*) .*$/\1/p' >version && \
    ${JS_BINARY} --help 2>&1 | sed -Ene 's/JavaScript-C (1[.0-9]*) (.* )?([0-9]{4}-[-0-9]+)$/\3/p' >revision_date
CMD ${JS_BINARY}
