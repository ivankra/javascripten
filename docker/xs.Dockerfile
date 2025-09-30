# https://github.com/Moddable-OpenSource/moddable/blob/public/documentation/Moddable%20SDK%20-%20Getting%20Started.md#lin-instructions
FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/Moddable-OpenSource/moddable.git
ARG JS_REV=public

WORKDIR /src
RUN git clone "$JS_REPO" . && git checkout "$JS_REV"

RUN apt-get update -y && apt-get install -y --no-install-recommends libncurses-dev
RUN cd xs/makefiles/lin && MODDABLE=/src make -j release  # -O3

ENV JS_BINARY=/src/build/bin/lin/release/xst
RUN ${JS_BINARY} -v | sed -e 's/^XS \([^, ]*\).*/\1/' >json.version
# No REPL
