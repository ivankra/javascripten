ARG BASE=jszoo-debian
FROM $BASE

ARG REPO=https://github.com/robertkrimen/otto.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN apt-get update -y && apt-get install -y golang
RUN cd otto && go build

ENV JS_BINARY=/src/otto/otto
CMD ${JS_BINARY}
