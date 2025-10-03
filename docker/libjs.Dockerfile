ARG BASE=jsz-clang
FROM $BASE

ARG REPO=https://github.com/LadybirdBrowser/ladybird.git
ARG REV=master

WORKDIR /src
RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

# https://github.com/LadybirdBrowser/ladybird/blob/master/Documentation/BuildInstructionsLadybird.md
RUN apt-get update -y && apt-get install -y autoconf autoconf-archive automake build-essential ccache cmake curl fonts-liberation2 git libdrm-dev libgl1-mesa-dev libtool nasm ninja-build pkg-config python3-venv qt6-base-dev qt6-tools-dev-tools qt6-wayland tar unzip zip qt6-multimedia-dev libpulse-dev
# LLVM installation (moved to base docker image)
#RUN wget -O /usr/share/keyrings/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key
#RUN echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg.key] https://apt.llvm.org/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc)-20 main" | sudo tee -a /etc/apt/sources.list.d/llvm.list
#RUN apt-get update -y && apt-get install -y clang-20 clangd-20 clang-tools-20 clang-format-20 clang-tidy-20 lld-20
#ENV CC=/usr/bin/clang-20 CXX=/usr/bin/clang++-20

RUN sed -i -e 's/geteuid() == 0/geteuid() == 42/' Meta/ladybird.py

# One command build wrapper
#RUN Meta/ladybird.py build --preset Release test262-runner js

# CMake build with static libs, without gui/vulkan deps
RUN Meta/ladybird.py vcpkg
RUN export ARCH=$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/') && \
    cmake \
      -S . -B Build/release --preset Release \
      -DCMAKE_MAKE_PROGRAM=ninja \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DBUILD_SHARED_LIBS=OFF \
      -DENABLE_GUI_TARGETS=OFF \
      -DENABLE_QT=OFF \
      -DVCPKG_TARGET_TRIPLET="$ARCH-linux-release"
RUN ninja -C Build/release test262-runner js

# GN build, doesn't work
#RUN sed -i -e 's/^exit_if_running_as_root/#/' Toolchain/BuildGN.sh
#RUN Toolchain/BuildGN.sh
#RUN Toolchain/Local/gn/bin/gn gen Build/release --args='host_cc="clang-20" host_cxx="clang++20" is_clang=true use_lld=true qt_install_headers="/usr/include/x86_64-linux-gnu/qt6/" qt_install_lib="/usr/lib/x86_64-linux-gnu" qt_install_libexec="/usr/lib/qt6/libexec/"'
#RUN ninja -C Build/release test262-runner js

ENV JS_BINARY=/src/Build/release/bin/js
CMD ${JS_BINARY}
