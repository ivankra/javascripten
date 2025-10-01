# V8 build from Chromium's tree with profile-guided optimizations.

ARG BASE=jszoo-clang
FROM $BASE

WORKDIR /src
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /src/depot_tools
ENV PATH=/src/depot_tools:$PATH

ARG REPO=https://chromium.googlesource.com/chromium/src.git
ARG REV=lkgr

# Fetch source with pgo profiles (for is_official_build=true)
RUN gclient config --name src "$REPO" --unmanaged --custom-var=checkout_pgo_profiles=True
RUN gclient sync --no-history --revision "src@$REV"

WORKDIR /src/src

# Build deps
RUN sed -i -e 's/ stable-updates$/ stable-updates bookworm/' /etc/apt/sources.list.d/debian.sources  # for the missing libpcre3-dev in trixie
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends rustc cargo build-essential gcc g++
RUN build/install-build-deps.sh --no-prompt

RUN export ARCH=$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/') && \
    export IS_CLANG=$(bash -c '[[ "$CC" == *gcc* ]] && echo false || echo true'); \
    mkdir -p out/release && \
    { \
      # third_party/llvm-build doesn't have prebuilt arm64 linux binaries, \
      # tell it to use host toolchain via //build/toolchain/linux/unbundle. \
      # CC, CXX, AR, NM must be set. \
      # Might also need to enable_rust=false \
      [ "$ARCH" = arm64 ] && echo \
        clang_use_chrome_plugins=false \
        clang_warning_suppression_file=\"\" \
        custom_toolchain=\"//build/toolchain/linux/unbundle:default\" \
        host_toolchain=\"//build/toolchain/linux/unbundle:default\" \
        is_clang=${IS_CLANG} \
        use_sysroot=false; \
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

ENV JS_BINARY=/src/src/out/release/d8
RUN ${JS_BINARY} -e 'console.log(version())' >json.version
CMD ${JS_BINARY}
