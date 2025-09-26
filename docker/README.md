# docker

Dockerfiles for building open-source JavaScript engines.

Prerequisites: Linux with podman/docker. Tested on x86-64 and arm64.

Make targets:
  * `make all`: build every Dockerfile
    * If some build fail, try deleting corresponding Dockerfile to keep going.
  * `make <engine>`: build a single engine, copy stripped binary to ../dist/
  * `make <engine>[-repl/-sh]`: build and drop into REPL/bash in build container
  * `make sh`: drop into bash in a throwaway test container with pre-installed
    libraries/runtimes and ../dist directory with all engines built so far.

When possible, engines are built statically from the original source code,
without libicu and Intl (ECMA-402 spec) as that adds a huge data dependency of
~10-20MB, that often gets embedded in the binary.
Temporal and WASM are disabled as well when possible to save space.

For major JIT engines, there are also "jitless" variants with JIT compiled out.

Naming convention for variants: `"engine[_variant].Dockerfile"` or
`engine.Dockerfile` with `JS_VARIANT` defined.
