#!/bin/bash
set -e -o pipefail

PUSHDEST="docker.io/ivankra/javascript-zoo"

DOCKER="$(command -v podman 2>/dev/null || echo docker)"
DOCKER_ARCH="$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/amd64/')"

ARCHS="arm64 amd64"
ARCHS=$(echo "$ARCHS" | sed -e "s/\b$DOCKER_ARCH\b//"; echo $DOCKER_ARCH)

set -x

for arch in $ARCHS; do
  $DOCKER build \
      -f base-runtime.Dockerfile \
      -t "jsz-hub:$arch" \
      --build-arg BASE=debian:stable \
      --platform "linux/$arch" \
      --target jsz-hub \
      ..
done

$DOCKER login docker.io

for tag in $(date +%Y%m%d) latest; do
  for arch in $ARCHS; do
    $DOCKER push "localhost/jsz-hub:$arch" "$PUSHDEST:$tag-$arch"
  done
  $DOCKER manifest rm "$PUSHDEST:$tag" || true
  $DOCKER manifest create "$PUSHDEST:$tag" $(for arch in $ARCHS; do echo "$PUSHDEST:$tag-$arch"; done)
  $DOCKER manifest push "$PUSHDEST:$tag" "$PUSHDEST:$tag"
done

echo OK
