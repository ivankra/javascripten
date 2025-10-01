# Debian-based build environment.
#
# Template for downstream containers:
#
#   ARG BASE=jszoo-debian
#   FROM $BASE
#
#   ARG REPO=<url>
#   ARG REV=<branch/tag/commit>
#
#   WORKDIR /src
#   RUN git clone "$REPO" . && git checkout "$REV"
#
#   (or sparse checkout with commit/branch/tag:)
#   RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
#       (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)
#
#   [ARG VARIANT=<variant>]
#
#   ...
#
#   ENV JS_BINARY=<path to javascript shell binary>
#   CMD <REPL command>

ARG BASE=debian:stable
FROM $BASE

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bash \
        bison \
        build-essential \
        bzip2 \
        ca-certificates \
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
