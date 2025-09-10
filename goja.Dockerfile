# JavaScript engine in pure Go.
#
# URL:      https://github.com/dop251/goja
# Standard: ES6 (partial)
# Tech:     stack VM
# Language: Go
# License:  MIT
# LOC:      46141 (cloc --fullpath --not_match_f="(?i)(test)" .)
# Timeline: 2016-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/dop251/goja.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y golang
RUN cd goja && go build

ENV JS_BINARY=/work/goja/goja
CMD ${JS_BINARY}
