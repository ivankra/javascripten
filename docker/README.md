# javascript-zoo/docker

Dockerfiles for building open-source JavaScript engines.

Prerequisites: Linux with podman (preferably) or docker.
Tested on x86-64 and arm64.

Make targets:
  * `make all`: build every Dockerfile
    * If some build fail, try deleting (or renaming with `_` prefix)
      corresponding Dockerfile or comment out entry in args.txt to keep going.
  * `make <name>`: build a single engine
    * Calls `./build.sh <name>[.Dockerfile]`: wrapper for `docker build`.
    * Then `./dist.sh <name>[.Dockerfile]`: strips and copies binary into
      `../dist/<arch>/<name>`, along with build metadata and auxialiry files.
  * `make <engine>[-repl/-sh]`: build and drop into REPL/bash in build container
  * `make sh`: drop into bash in a throwaway test container with pre-installed
    libraries/runtimes and dist directory with all engines built so far.
  * `make hub`: create a multiarch version of `sh` container for publishing.
    Prerequisite: `sudo apt install qemu-user-static`.

Some targets have several build variants, e.g. `*_jitless` variants with
JIT compiled out. Naming convention: `engine_variant`. Variant-specific
build arguments are defined in `args.txt`. It is also used to pin
specific revisions.

Most engines are built statically from the original source code, without
libicu and Intl (ECMA-402) as that adds a huge data dependency of ~10-20MB,
that often gets embedded in the binary. Temporal and WASM are disabled
as well when possible to save space.

## Docker Hub

Container with pre-built binaries on
[Docker Hub](https://hub.docker.com/r/ivankra/javascript-zoo):

  * `docker run -it ivankra/javascript-zoo`
  * `podman run -it docker.io/ivankra/javascript-zoo`

## Template

Template for adding a new engine:

```Dockerfile
ARG BASE=jszoo-gcc
FROM $BASE

ARG REPO=
ARG REV=master

WORKDIR /src
RUN git clone "$REPO" . && git checkout "$REV"

# Or shallow clone for large repositories:
#RUN git clone --depth=1 --branch="$REV" "$REPO" . || \
#    (git clone --depth=1 "$REPO" . && git fetch --depth=1 origin "$REV" && git checkout FETCH_HEAD)

RUN make -j

ENV JS_BINARY=<path to javascript shell binary>

# Point WORKDIR to source directory for dist.sh to get metadata from git.
# Tweak metadata if needed: drop json.<key> files in source or /dist dir.
#RUN ${JS_BINARY} --version >json.version

# REPL command:
CMD ${JS_BINARY}
```
