FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/adobe/avmplus.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"
