FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/mozilla/rhino

RUN apt-get install -y --no-install-recommends rhino

ENV JS_BINARY=/usr/bin/rhino
RUN dpkg-query -W -f='${Version}\n' rhino >version
CMD ${JS_BINARY} -opt 9
