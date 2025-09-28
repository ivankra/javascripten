#!/bin/bash

set -e

ID="$1"
if [[ -z "$ID" ]]; then
  echo "Usage: ./build.sh <name>[.Dockerfile]"
  exit 1
fi

ID=${ID%.Dockerfile}

ARCH=$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/')
DOCKER=$(command -v podman 2>/dev/null || echo docker)
IID_DIR=../.cache/iid
DIST_DIR=../dist/$ARCH

mkdir -p "$IID_DIR" "$DIST_DIR"
rm -f $DIST_DIR/$ID.json

ARGS=$(sed -ne "s/^$ID: *//p" args.txt 2>/dev/null)
if [[ "$ARGS" != *-f* ]]; then
  ARGS="-f $ID.Dockerfile $ARGS"
fi

set -x
$DOCKER build -t "javascripten-$ID" --iidfile="$IID_DIR/$ID" $ARGS .
