# JavaScript engine from Mozilla for the Java platform, bundled with JDK 6-7.
#
# URL:      https://rhino.github.io/
# Standard: ES5, some ES6+
# Tech:     JVM, tree-walker / compiler to unoptimized JVM bytecode
# Language: Java
# License:  MPL-2.0
# Org:      Mozilla
# LOC:      83848 (cloc --not_match_d="(?i)(test)" rhino)
# Timeline: 1997-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/mozilla/rhino

RUN apt-get install -y --no-install-recommends rhino

ENV JS_BINARY=/usr/bin/rhino
RUN dpkg-query -W -f='${Version}\n' rhino >version
CMD ${JS_BINARY} -opt 9
