# Building V8:
#   * https://v8.dev/docs/build-gn
#   * https://v8.dev/docs/compile-arm64
#   * https://www.chromium.org/developers/gn-build-configuration/
FROM javascripten-debian:stable

# Fetch v8 source (from https://chromium.googlesource.com/v8/v8.git), lkgr='last known good revision'
ARG JS_COMMIT=lkgr
WORKDIR /work
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /work/depot_tools
ENV PATH=/work/depot_tools:$PATH
RUN fetch --nohooks --nohistory v8
WORKDIR /work/v8
RUN git fetch --depth=1 origin "$JS_COMMIT" && git checkout "$JS_COMMIT" && gclient sync

RUN sed -i -e 's/ stable-updates$/ stable-updates bookworm/' /etc/apt/sources.list.d/debian.sources  # for the missing libpcre3-dev in trixie
RUN build/install-build-deps.sh --no-prompt
#RUN tools/dev/gm.py x64.release-d8  # can do basic x64 build, but no customizations, fails for arm64 on linux

RUN uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/' >arch && \
    { \
      echo "is_component_build=false"; \
      echo "is_debug=false"; \
      echo "is_official_build=true"; \
      echo "chrome_pgo_phase=0"; \
      echo "generate_linker_map=true"; \
      # Slim binary size: \
      echo "v8_enable_i18n_support=false"; \
      echo "v8_enable_temporal_support=false"; \
      echo "v8_enable_gdbjit=false"; \
      echo "v8_enable_disassembler=false"; \
      echo "v8_enable_webassembly=false"; \
      echo "v8_use_external_startup_data=false"; \
    } >args && \
    gn gen out/$(cat arch).release-d8 --args="$(cat args | grep -v '^[^a-z]' | tr '\n' ' ')"
RUN ninja -C out/*.release-d8

ENV JS_BINARY=/work/v8/out/x64.release-d8/d8
CMD ${JS_BINARY}

#arm64 unsuccessful build:
#RUN python build/linux/sysroot_scripts/install-sysroot.py --arch=$(cat /arch)
#RUN tools/clang/scripts/build.py --without-android --without-fuchsia --host-cc=gcc --host-cxx=g++ --use-system-cmake --disable-asserts --with-ml-inliner-model=""
#RUN tools/rust/build_rust.py  # fails at arm64 + linux platform
# for is_official_build (optimized release) with pgo
#RUN echo 'solutions = [{"name": "v8", "url": "https://chromium.googlesource.com/v8/v8.git", "deps_file": "DEPS", "managed": False, "custom_vars": {"checkout_pgo_profiles": True}}]' >.gclient && gclient sync
