# LLRT: lightweight QuickJS/Tokio-based runtime
#
# URL: https://github.com/awslabs/llrt

FROM javascripten-sh

# Precompiled release
ENV JS_BINARY=/usr/local/bin/llrt
CMD ${JS_BINARY}
