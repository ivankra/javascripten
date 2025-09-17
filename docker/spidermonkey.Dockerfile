FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/mozilla-firefox/firefox
ARG JS_COMMIT=release

WORKDIR /work
RUN git clone --branch="$JS_COMMIT" --depth=1 "$JS_REPO" .

RUN apt-get update -y && apt-get install -y libxml2 libz-dev libicu-dev python3-pip python3-psutil clang cargo rustc cbindgen

# Build instructions: https://firefox-source-docs.mozilla.org/js/build.html
# Run './js/src/configure --help' for configure options.
RUN { \
      echo "ac_add_options --enable-project=js"; \
      echo "ac_add_options --enable-jit"; \
      echo "ac_add_options --enable-optimize"; \
      echo "ac_add_options --enable-release"; \
      echo "ac_add_options --enable-strip"; \
      echo "ac_add_options --disable-debug"; \
      echo "ac_add_options --disable-debug-symbols"; \
      echo "ac_add_options --disable-tests"; \
      echo "ac_add_options --without-intl-api"; \
      echo "ac_add_options --disable-icu4x"; \
    } >MOZCONFIG
RUN MOZCONFIG=/work/MOZCONFIG ./mach build
RUN ln -s obj-*/ obj

ENV JS_BINARY=/work/obj/dist/bin/js
RUN ${JS_BINARY} -v | egrep -o [0-9.]+ >version
CMD ${JS_BINARY}
