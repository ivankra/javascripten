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
      -f sh.Dockerfile \
      -t "jszoo-sh:$arch" \
      --platform="linux/$arch" \
      --build-arg BASE=debian:stable \
      ..
  $DOCKER build \
      -f hub.Dockerfile \
      -t "jszoo-hub:$arch" \
      --platform="linux/$arch" \
      --build-arg BASE="jszoo-sh:$arch" \
      ..
done

$DOCKER login docker.io

for tag in $(date +%Y%m%d) latest; do
  for arch in $ARCHS; do
    $DOCKER push "localhost/jszoo-hub:$arch" "$PUSHDEST:$tag-$arch"
  done
  $DOCKER manifest rm "$PUSHDEST:$tag" || true
  $DOCKER manifest create "$PUSHDEST:$tag" $(for arch in $ARCHS; do echo "$PUSHDEST:$tag-$arch"; done)
  $DOCKER manifest push "$PUSHDEST:$tag" "$PUSHDEST:$tag"
done

echo OK
