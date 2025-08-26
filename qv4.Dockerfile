# https://wiki.qt.io/V4
# https://github.com/qt/qtdeclarative/blob/dev/src/qml/jsapi/qjsengine.cpp
FROM javascripten-debian:stable

ARG JS_REPO=https://code.qt.io/qt/qt5.git
ARG JS_COMMIT=v6.9.1

WORKDIR /work
RUN git clone --depth=1 --branch="$JS_COMMIT" "$JS_REPO" .
RUN git submodule update --depth=1 --init --recursive qtbase qtdeclarative

RUN cmake -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=OFF \
      -DQT_FEATURE_shared=OFF \
      -DQT_FEATURE_static=ON \
      -DQT_FEATURE_gui=OFF \
      -DQT_FEATURE_network=OFF \
      -DQT_FEATURE_private_tests=ON
RUN ninja -C build qmljs

ENV JS_BINARY=/work/build/qtbase/bin/qmljs
CMD ${JS_BINARY}
