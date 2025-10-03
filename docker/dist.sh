#!/bin/bash
# This script is run after a successful build to strip and copy built binaries
# out of build containers to ../dist/<arch>/, along with a metadata .json file.

set -e

ID="$1"
if [[ -z "$ID" ]]; then
  echo "Usage: ./dist.sh <name>[.Dockerfile]"
  exit 1
fi

ID=${ID%.Dockerfile}

ARCH=$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/amd64/')
DOCKER=$(command -v podman 2>/dev/null || echo docker)

mkdir -p "../dist/$ARCH"
rm -rf "../dist/$ARCH/$ID" >/dev/null 2>&1
rm -rf "../dist/$ARCH/$ID".* >/dev/null 2>&1

CIDFILE="../.cache/cid/$ID"
mkdir -p "../.cache/cid"

if [[ -f $CIDFILE ]]; then
  $DOCKER rm "$(cat "$CIDFILE")" >/dev/null 2>&1 || true
  rm -f "$CIDFILE"
fi

# Prepare /dist directory inside container
$DOCKER run --cidfile="$CIDFILE" "jsz-$ID" /bin/bash -e -c "$(cat <<EOF
mkdir -p /dist

if [[ "\$JS_BINARY" != "" && ! -f "\$JS_BINARY" ]]; then
  echo "Error: JS_BINARY=\$JS_BINARY doesn't exist"
  exit 1
fi

if [[ \$(file -b --mime-type "\$JS_BINARY" 2>/dev/null) == */*-executable ]]; then
  rm -f "/dist/$ID" || true
  strip -o "/dist/$ID" "\$JS_BINARY"
  sha256sum "/dist/$ID" | cut -f 1 -d ' ' >/dist/jsz_binary_sha256
  ls -l "/dist/$ID" 2>/dev/null | sed -e 's/  */ /g' | cut -f 5 -d ' ' >/dist/jsz_binary_size
fi

SRC="\$(pwd)"

for f in jsz_*; do
  if [[ -f "\$f" && ! -f "/dist/\$f" ]]; then
    cp -f "\$f" "/dist/\$f"
  fi
done

if [[ -d .git ]]; then
  git rev-parse HEAD >/dist/jsz_revision
  git log -1 --format='%ad' --date=short HEAD >/dist/jsz_revision_date
  git remote get-url origin >/dist/jsz_repository

  if ! [[ -f /dist/jsz_version ]] && git describe --tags HEAD >/dev/null 2>/dev/null; then
    git describe --tags HEAD >/dist/jsz_version 2>/dev/null
  fi
fi

cd /dist

ID="$ID"

ENGINE="\${ID%_*}"
echo "\$ENGINE" >jsz_engine

if [[ "\$ID" == *_* ]]; then
  VARIANT="\${ID#*_}"
  echo "\$VARIANT" >jsz_variant
fi

echo "$ARCH" >jsz_arch

# Assemble /dist/$ID.json from value fragments in /dist/jsz_*
{
  echo "{"
  for f in jsz_*; do
    key=\${f#jsz_}
    if [[ \$key == binary_size || \$key == loc ]]; then
      val=\$(cat "\$f")
    else
      val=\$(cat "\$f" | python -c 'import sys, json; print(json.dumps(sys.stdin.read().strip()));')
    fi
    echo "  \"\$key\": \$val,"
    rm -f "\$f"
  done
} | sed '$ s/,$//' >$ID.json
echo "}" >>$ID.json

ls -l /dist | grep -v ^total

exit 0;
EOF
)"

# Copy dist directory's contents to ../dist/<arch>/

CID=$(cat "$CIDFILE")
TMPCP="../.cache/dist-tmp-$ID"
rm -rf "$TMPCP"
mkdir -p "$TMPCP"
$DOCKER cp "$CID":/dist "$TMPCP"

for src in "$TMPCP/dist/$ID"*; do
  if [[ -e "$src" ]]; then
    mkdir -p "../dist/$ARCH"
    dst="../dist/$ARCH/$(basename "$src")"
    if [[ -e "$dst" ]]; then
      chmod a+w "$dst"
      rm -rf "$dst"
    fi
    mv -f "$src" "$dst"
    if [[ -f "$dst" ]]; then
      chmod a-w "$dst"
    fi
  fi
done

$DOCKER rm "$CID" >/dev/null
rm -rf "$TMPCP" "$CIDFILE"

exit 0
