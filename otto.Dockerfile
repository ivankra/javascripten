# JavaScript engine in pure Go
#
# URL:      https://github.com/robertkrimen/otto
# Standard: ES5
#   * non-compliant regex engine from Go
# Tech:     tree-walker
# Language: Go
# License:  MIT
# LOC:      26462 (cloc --fullpath --not_match_f="(?i)(test)" .)
# Timeline: 2012-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/robertkrimen/otto.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get update -y && apt-get install -y golang
RUN cd otto && go build

ENV JS_BINARY=/work/otto/otto
CMD ${JS_BINARY}
