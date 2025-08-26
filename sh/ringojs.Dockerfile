# RingoJS: Rhino-based runtime for JVM.
#
# URL: https://github.com/ringo/ringojs

FROM javascripten-sh

# Precompiled release
ENV JS_BINARY_LINK=/usr/local/bin/ringojs
CMD ${JS_BINARY_LINK}
