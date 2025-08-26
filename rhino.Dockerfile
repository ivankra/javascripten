# URL: https://github.com/mozilla/rhino

FROM javascripten-debian:stable

RUN apt-get install -y --no-install-recommends rhino

ENV JS_BINARY_LINK=/usr/bin/rhino
CMD ${JS_BINARY_LINK}
