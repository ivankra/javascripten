ARG BASE=jsz-gcc
FROM $BASE

ARG REPO=https://code.qt.io/qt/qt5.git
ARG REV=dev

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)
RUN git submodule update --depth=1 --init --recursive qtbase qtdeclarative

ARG VARIANT=

RUN cmake -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=OFF \
      -DQT_FEATURE_shared=OFF \
      -DQT_FEATURE_static=ON \
      -DQT_FEATURE_gui=OFF \
      -DQT_FEATURE_network=OFF \
      -DQT_FEATURE_private_tests=ON \
      -DQT_FEATURE_qml_animation=OFF \
      -DQT_FEATURE_qml_debug=OFF \
      -DQT_FEATURE_qml_jit="$([ "$VARIANT" = jitless ] && echo OFF || echo ON)" \
      -DQT_FEATURE_qml_locale=OFF \
      -DQT_FEATURE_qml_network=OFF \
      -DQT_FEATURE_qml_profiler=OFF
RUN ninja -C build qmljs

ENV JS_BINARY=/src/build/qtbase/bin/qmljs
CMD ${JS_BINARY}
