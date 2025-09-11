FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/ferus-web/bali.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN sed -i -e 's/ stable-updates$/ stable-updates unstable/' /etc/apt/sources.list.d/debian.sources
RUN apt-get update -y && apt-get install -y nim libgmp-dev libicu-dev libgc-dev
RUN git clone https://github.com/simdutf/simdutf && cd simdutf && cmake . && sudo make install . -j
RUN nimble refresh && nimble install && make NIMFLAGS="--define:release --define:baliTest262FyiDisableICULinkingCode --define:speed"

ENV JS_BINARY=/work/bin/balde
CMD ${JS_BINARY}
