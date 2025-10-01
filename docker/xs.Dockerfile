# https://github.com/Moddable-OpenSource/moddable/blob/public/documentation/Moddable%20SDK%20-%20Getting%20Started.md#lin-instructions
ARG BASE=jszoo-gcc
FROM $BASE

ARG REPO=https://github.com/Moddable-OpenSource/moddable.git
ARG REV=public

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN apt-get update -y && apt-get install -y --no-install-recommends libncurses-dev
RUN cd xs/makefiles/lin && MODDABLE=/src make -j release  # -O3

ENV JS_BINARY=/src/build/bin/lin/release/xst
RUN ${JS_BINARY} -v | sed -e 's/^XS \([^, ]*\).*/\1/' >json.version
# No REPL
