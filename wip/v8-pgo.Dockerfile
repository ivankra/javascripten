# Build of V8 from Chromium's tree with profile-guided optimizations.

FROM javascripten-debian:stable

# lkgr='last known good revision'
ARG JS_COMMIT=lkgr

WORKDIR /work
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /work/depot_tools
ENV PATH=/work/depot_tools:$PATH

# Fetch source with pgo profiles (for is_official_build=true)
RUN gclient config --name src https://chromium.googlesource.com/chromium/src.git --unmanaged --custom-var=checkout_pgo_profiles=True
RUN gclient sync --no-history --revision "src@${JS_COMMIT}"

WORKDIR /work/src

# Build deps
RUN sed -i -e 's/ stable-updates$/ stable-updates bookworm/' /etc/apt/sources.list.d/debian.sources  # for the missing libpcre3-dev in trixie
RUN /work/src/build/install-build-deps.sh --no-prompt

# Use debian's clang for //build/toolchain/linux/unbundle
RUN apt-get update -y && apt-get install -y clang lld rustc cargo
ENV CC=/usr/bin/clang CXX=/usr/bin/clang++ AR=/usr/bin/llvm-ar NM=/usr/bin/llvm-nm

RUN export ARCH=$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/') && \
    mkdir -p out/release && \
    { \
      # third_party/llvm-build doesn't have prebuilt arm64 linux binaries so \
      # use host toolchain. Might also need to enable_rust=false \
      if [ "$ARCH" = "arm64" ]; then echo \
        clang_use_chrome_plugins=false \
        clang_warning_suppression_file=\"\" \
        custom_toolchain=\"//build/toolchain/linux/unbundle:default\" \
        host_toolchain=\"//build/toolchain/linux/unbundle:default\" \
        is_clang=true \
        use_sysroot=false; \
      fi; \
      # Full release build, trim some fat. \
      echo \
        dcheck_always_on=false \
        is_component_build=false \
        is_debug=false \
        is_official_build=true \
        target_cpu='"'$ARCH'"' \
        treat_warnings_as_errors=false \
        v8_enable_disassembler=false \
        v8_enable_gdbjit=false \
        v8_enable_i18n_support=false \
        v8_enable_sandbox=false \
        v8_enable_temporal_support=false \
        v8_enable_test_features=false \
        v8_enable_webassembly=false \
        v8_target_cpu='"'$ARCH'"' \
        v8_use_external_startup_data=false; \
    } | tr ' ' '\n' >out/release/args.gn

RUN gn gen out/release/
RUN autoninja -C out/release/ d8

ENV JS_BINARY=/work/src/out/release/d8
RUN ${JS_BINARY} -e 'console.log(version())' >version
CMD ${JS_BINARY}
