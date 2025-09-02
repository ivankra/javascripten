# Rhino-based runtime for JVM.
#
# URL: https://github.com/ringo/ringojs

FROM javascripten-sh

# Precompiled release from github
ENV JS_BINARY=/usr/local/bin/ringojs
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+.*' >version
CMD ${JS_BINARY}
