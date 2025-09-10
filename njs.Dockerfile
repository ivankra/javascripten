# Lightweight embeddable JavaScript engine for use in nginx.
# Fails checksum in RegExp test.
#
# URL:      https://nginx.org/en/docs/njs/index.html
# Standard: ES6+ (partial)
# Tech:     register VM, PCRE2
# Language: C
# License:  BSD-2-Clause
# Org:      Nginx
# LOC:      58962 (cloc --not_match_d="(?i)(test)" src)
# Timeline: 2015-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/nginx/njs.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y --no-install-recommends libpcre2-dev libedit-dev
RUN ./configure --cc-opt="-O2" --no-openssl --no-libxml2 --no-quickjs --no-zlib && make -j

ENV JS_BINARY=/work/build/njs
CMD ${JS_BINARY}
