ARG BASE=jszoo-debian
FROM $BASE

ARG REPO=https://github.com/ferus-web/bali.git
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

RUN sed -i -e 's/ stable-updates$/ stable-updates unstable/' /etc/apt/sources.list.d/debian.sources
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends nim libgmp-dev libicu-dev libgc-dev

RUN git clone https://github.com/simdutf/simdutf && cd simdutf && cmake . && sudo make install . -j

RUN nimble refresh && \
    nimble install && \
    make NIMFLAGS="--define:release --define:baliTest262FyiDisableICULinkingCode --define:speed"

ENV JS_BINARY=/src/bin/balde
CMD ${JS_BINARY}
