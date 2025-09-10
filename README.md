# JavaScript engines zoo

Docker files for building open-source JavaScript/ECMAScript engines,
for playing around and benchmarking.

## Building

Prerequisites: Linux with podman/docker. Builds tested on x86-64 and arm64.

Make targets:
  * `make all`: build everything
  * `make <engine>[-sh]`: build a single engine and drop into its REPL or bash
  * `make bin`: strip and copy built binaries into ./bin directory
  * `make sh`: drop into bash in a throwaway test container with pre-installed
    libraries/runtimes and ./bin directory with all engines built so far.

There is a single Dockerfile per engine, and some Dockerfiles for JavaScript
runtimes (node/deno/bun etc) in `sh/` that are installed in test container
for easy comparison.

`make all` will attempt to build every file it finds - if some build fail,
delete corresponding Dockerfile to keep going.

When possible, engines are built statically from original source
code, without libicu and Intl (ECMA-402 spec) as that adds a huge data
dependency of ~10-20MB, that often gets embedded in the binary. Temporal
and WASM is disabled as well when possible to save space. For major JIT
engines, there are also "jitless" variants with JIT compiled out.
