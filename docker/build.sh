#!/bin/bash
# Wrapper for 'podman build'

set -e

DEP=0
if [[ "$1" == "--dep" ]]; then
  DEP=1
  shift
fi

ID="$1"
if [[ -z "$ID" ]]; then
  echo "Usage: ./build.sh <name>[.Dockerfile]"
  exit 1
fi

ID=${ID%.Dockerfile}

DOCKER="$(command -v podman 2>/dev/null || echo docker)"
DOCKER_ARCH="$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/amd64/')"
IID_DIR="../.cache/iid"
DIST_DIR="../dist/$DOCKER_ARCH"

ARGS=$(sed -ne "s/^$ID: *//p" args.txt 2>/dev/null)

# Print dependencies for Makefile
if [[ "$DEP" == 1 ]]; then
  echo "$IID_DIR/build"
  if [[ "$ARGS" != "" ]]; then
    echo args.txt
  fi
  if [[ $ARGS =~ -f[[:space:]]([-a-z0-9_.]+.Dockerfile) ]]; then
    echo ${BASH_REMATCH[1]}
  fi
  if [[ -f $ID.Dockerfile ]]; then
    echo $ID.Dockerfile
  fi
  exit 0
fi

if [[ "$ARGS" != *-f* ]]; then
  ARGS="-f $ID.Dockerfile $ARGS"
fi

mkdir -p "$IID_DIR" "$DIST_DIR"
rm -f "$DIST_DIR/$ID.json"

set -x
$DOCKER build --platform="linux/$DOCKER_ARCH" --iidfile="$IID_DIR/$ID" -t "jszoo-$ID" $ARGS .
