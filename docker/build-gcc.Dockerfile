# GCC-based build environment.

ARG BASE=jszoo-debian
FROM $BASE

ARG VER=14

# Add sid repository in DEB822 format, with low priority, for gcc 15.
# TODO: use heredoc after upgrading to podman 5+
RUN if [ "$VER" = 15 ]; then \
      apt-get remove -y --purge build-essential gcc g++ gcc-14 g++-14 cpp-14 libstdc++-14-dev; \
      apt-get autoremove -y; \
      { \
        echo "Types: deb"; \
        echo "URIs: http://deb.debian.org/debian"; \
        echo "Suites: sid"; \
        echo "Components: main"; \
        echo "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg"; \
      } >/etc/apt/sources.list.d/sid.sources && \
      { \
        echo "Package: *"; \
        echo "Pin: release a=sid"; \
        echo "Pin-Priority: 1"; \
      } >/etc/apt/preferences.d/sid; \
    fi

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends $(if [ "$VER" = 15 ]; then echo -t sid; fi) \
        binutils \
        build-essential \
        g++-$VER \
        gcc-$VER \
        libstdc++-$VER-dev \
        libtool

# V8's build system needs these four to be explicitly set
ENV CC=/usr/bin/gcc-$VER CXX=/usr/bin/g++-$VER AR=/usr/bin/ar NM=/usr/bin/nm

# Record compiler's version in build metadata.
RUN mkdir -p /dist && $CC -v 2>&1 | sed -ne 's/ *$//; s/.*gcc version /gcc /p' >/dist/json.cc
