# Lightweight QuickJS/tokio-based runtime.
#
# URL: https://github.com/awslabs/llrt

FROM javascripten-sh

# Precompiled release from github
ENV JS_BINARY=/usr/local/bin/llrt
RUN ${JS_BINARY} -v | egrep -o '[0-9.]+[^ ]*' | head -1 >version
CMD ${JS_BINARY}
