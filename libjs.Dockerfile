# JavaScript engine of Ladybird browser and SerenityOS.
#
# URL:      https://ladybirdbrowser.github.io/libjs-website/
# Standard: ESnext
# Tech:     register VM
# Language: C++
# License:  BSD-2-Clause
# LOC:      72562 (cloc --not_match_d="(?i)(test)" Libraries/LibJS)
# Timeline: 2020-

FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/LadybirdBrowser/ladybird.git
ARG JS_COMMIT=master

WORKDIR /work
RUN git clone --depth=1 --branch="$JS_COMMIT" "$JS_REPO" .

# https://github.com/LadybirdBrowser/ladybird/blob/master/Documentation/BuildInstructionsLadybird.md
RUN apt-get update -y && apt-get install -y autoconf autoconf-archive automake build-essential ccache cmake curl fonts-liberation2 git libdrm-dev libgl1-mesa-dev nasm ninja-build pkg-config python3-venv qt6-base-dev qt6-tools-dev-tools qt6-wayland tar unzip zip qt6-multimedia-dev libpulse-dev
RUN wget -O /usr/share/keyrings/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key
RUN echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg.key] https://apt.llvm.org/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc)-20 main" | sudo tee -a /etc/apt/sources.list.d/llvm.list
RUN apt-get update -y && apt-get install -y clang-20 clangd-20 clang-tools-20 clang-format-20 clang-tidy-20 lld-20
ENV CC=/usr/bin/clang-20 CXX=/usr/bin/clang++-20
RUN sed -i -e 's/geteuid() == 0/geteuid() == 42/' Meta/ladybird.py

# One command build wrapper
#RUN Meta/ladybird.py build --preset Release test262-runner js

# CMake build with static libs, without gui/vulkan deps
RUN Meta/ladybird.py vcpkg
RUN cmake --preset Release -S . -B Build/release -DCMAKE_MAKE_PROGRAM=ninja -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DBUILD_SHARED_LIBS=OFF -DENABLE_GUI_TARGETS=OFF -DENABLE_QT=OFF -DVCPKG_TARGET_TRIPLET="$(uname -a | egrep -qi '(arm64|aarch64)' && echo arm64-linux-release || echo x64-linux-release)"
RUN ninja -C Build/release test262-runner js

# GN build, doesn't work
#RUN sed -i -e 's/^exit_if_running_as_root/#/' Toolchain/BuildGN.sh
#RUN Toolchain/BuildGN.sh
#RUN Toolchain/Local/gn/bin/gn gen Build/release --args='host_cc="clang-20" host_cxx="clang++20" is_clang=true use_lld=true qt_install_headers="/usr/include/x86_64-linux-gnu/qt6/" qt_install_lib="/usr/lib/x86_64-linux-gnu" qt_install_libexec="/usr/lib/qt6/libexec/"'
#RUN ninja -C Build/release test262-runner js

ENV JS_BINARY=/work/Build/release/bin/js
CMD ${JS_BINARY}
