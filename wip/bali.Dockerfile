FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/ferus-web/bali.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN sed -i -e 's/ stable-updates$/ stable-updates unstable/' /etc/apt/sources.list.d/debian.sources
RUN apt-get update -y && apt-get install -y nim
RUN nimble build

#ENV JS_BINARY=
#CMD ${JS_BINARY}
