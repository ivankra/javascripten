# Debian-based build environment.

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

#ENV LC_ALL=en_US.UTF-8
