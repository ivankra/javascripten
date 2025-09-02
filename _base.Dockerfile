# Debian-based build environment, common for all images.
#
# Convention for downstream containers:
#   FROM javascripten-debian:stable
#   ARG JS_REPO=<url> JS_COMMIT=<branch/tag/commit>
#   WORKDIR <repo checkout location>
#   ...
#   ENV JS_BINARY=<path to built binary>
#   CMD <REPL command>
#
ARG SOURCE=debian:stable
FROM ${SOURCE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bash \
        bison \
        build-essential \
        ca-certificates \
        clang \
        cloc \
        cmake \
        curl \
        file \
        findutils \
        flex \
        gdb \
        gettext \
        git \
        gperf \
        gzip \
        less \
        libtool \
        llvm \
        locales \
        lsb-release \
        make \
        ninja-build \
        perl \
        pkg-config \
        python-is-python3 \
        python3 \
        python3-pip \
        python3-venv \
        python3-yaml \
        ripgrep \
        ruby \
        sudo \
        tar \
        unzip \
        vim \
        wget \
        xz-utils \
        zip && \
    echo "en_US.UTF-8 UTF-8" >/etc/locale.gen && \
    locale-gen

# TODO: clang-21 lld python3-pip python3-psutil cargo rustc cbindgen
