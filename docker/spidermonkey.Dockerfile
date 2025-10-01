ARG BASE=jszoo-clang
FROM $BASE

ARG REPO=https://github.com/mozilla-firefox/firefox
ARG REV=release

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        cargo \
        cbindgen \
        libicu-dev \
        libxml2 \
        libz-dev \
        python3-pip \
        python3-psutil \
        rustc

# jitless: like --no-jit-backend cli flag, NOT same as: --no-ion --no-baseline --no-asmjs --no-native-regexp !
ARG VARIANT=

# Build instructions: https://firefox-source-docs.mozilla.org/js/build.html
# Run './js/src/configure --help' for configure options.
RUN { \
      echo "ac_add_options --enable-project=js"; \
      if [ "$VARIANT" = jitless ]; then \
        echo "ac_add_options --disable-jit"; \
      else \
        echo "ac_add_options --enable-jit"; \
      fi; \
      echo "ac_add_options --enable-optimize"; \
      echo "ac_add_options --enable-release"; \
      echo "ac_add_options --enable-strip"; \
      echo "ac_add_options --disable-debug"; \
      echo "ac_add_options --disable-debug-symbols"; \
      echo "ac_add_options --disable-tests"; \
      echo "ac_add_options --without-intl-api"; \
      echo "ac_add_options --disable-icu4x"; \
    } >MOZCONFIG
RUN MOZCONFIG=/src/MOZCONFIG ./mach build
RUN ln -s obj-*/ obj

ENV JS_BINARY=/src/obj/dist/bin/js
RUN ${JS_BINARY} -v | egrep -o [0-9.]+ >json.version
CMD ${JS_BINARY}
