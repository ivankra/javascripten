# Clang-based build environment.

ARG BASE=jszoo-debian
FROM $BASE

ARG VER=20

RUN apt-get remove -y build-essential gcc g++ gcc-14 g++-14 libstdc++-14-dev && apt-get autoremove -y
# Note: removes libtool - depends on gcc

RUN wget -O /usr/share/keyrings/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key
RUN echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg.key] https://apt.llvm.org/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc)-$VER main" >>/etc/apt/sources.list.d/llvm.list

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        clang-$VER \
        clang-format-$VER \
        clang-tidy-$VER \
        clang-tools-$VER \
        clangd-$VER \
        libc++-$VER-dev \
        libc++abi-$VER-dev \
        lld-$VER \
        lldb-$VER \
        llvm-$VER

# V8's build system needs these four to be explicitly set
ENV CC=/usr/bin/clang-$VER CXX=/usr/bin/clang++-$VER AR=/usr/bin/llvm-ar-$VER NM=/usr/bin/llvm-nm-$VER

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-$VER 150 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-$VER 150 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$VER 150 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$VER 150 && \
    update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-$VER 150 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-$VER 150 && \
    update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-$VER 150 && \
    update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-$VER 150

# Record compiler's version in build metadata.
RUN mkdir -p /dist && $CC -v 2>&1 | sed -ne 's/.*clang version /clang /p' >/dist/json.cc

# Verify binaries: readelf -p .comment <binary>
