#!/bin/bash
# Run after a successful build to prepare /dist directory.
# Strips binary, writes <image>.json, copies files out to ../dist/<arch>,

set -e

ID="$1"
if [[ -z "$ID" ]]; then
  echo "Usage: ./dist.sh <name>[.Dockerfile]"
  exit 1
fi

ID=${ID%.Dockerfile}

ARCH=$(uname -m | sed -e 's/aarch64/arm64/; s/x86_64/x64/')
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

$DOCKER run --cidfile="$CIDFILE" "javascripten-$ID" /bin/bash -e -c "$(cat <<EOF
mkdir -p /dist
if [[ ! -f "/dist/$ID" && -f "\$JS_BINARY" && \
      \$(file -b --mime-type "\$JS_BINARY" 2>/dev/null) == */*-executable ]]; then
  strip -o "/dist/$ID" "\$JS_BINARY"
fi

SRC="\$(pwd)"

for f in json.*; do
  if [[ -f "$f" && ! -f /dist/$f ]]; then
    cp -f "$f" "/dist/$f"
  fi
done

if [[ -d .git ]]; then
  git rev-parse HEAD >/dist/json.revision
  git log -1 --format='%ad' --date=short HEAD >/dist/json.revision_date
  git remote get-url origin >/dist/json.repository

  if ! [[ -f /dist/json.version ]]; then
    (git describe --tags HEAD 2>/dev/null || git rev-parse --short=8 HEAD) \
      | sed -e s/^v// >/dist/json.version
  fi
fi

cd /dist

ID="$ID"
JS_ENGINE="\${JS_ENGINE:-\${ID%_*}}"
if [[ "$ID" == *_* ]]; then
  JS_VARIANT="\${JS_VARIANT:-\${ID#*_}}"
fi

echo "$ARCH" >json.arch
echo "\$JS_ENGINE" >json.engine
if [[ -n "\$JS_VARIANT" ]]; then
  echo "\$JS_VARIANT" >json.variant
fi

if [[ ! -f json.binary_size && \$(file -b --mime-type "$ID" 2>/dev/null) == */*-executable ]]; then
  ls -l "$ID" 2>/dev/null | sed -e 's/  */ /g' | cut -f 5 -d ' ' >json.binary_size
fi

# Assemble /dist/$ID.json from value fragments in /dist/json.*
{
  echo "{"
  for f in json.*; do
    key=\${f#json.}
    val=\$(cat "\$f")
    if [[ \$key == binary_size ]]; then
      echo "  \"binary_size\": \$val,"
    else
      echo "  \"\$key\": \\"\$val\\","
    fi
    rm -f "\$f"
  done
} | sed '$ s/,$//' >$ID.json
echo "}" >>$ID.json

ls -l /dist | grep -v ^total

exit 0;
EOF
)"

CID=$(cat "$CIDFILE")
TMPCP="../.cache/cp-$ID"
rm -rf "$TMPCP"
mkdir -p "$TMPCP"
$DOCKER cp "$CID":/dist "$TMPCP"

for f in "$TMPCP/dist/$ID"*; do
  if [[ -e "$f" ]]; then
    #echo "$ID:/dist/$(basename "$f") -> ../dist/$ARCH/$(basename "$f")"
    mkdir -p "../dist/$ARCH"
    rm -rf "../dist/$ARCH/$(basename "$f")"
    /bin/cp -af "$f" "../dist/$ARCH/"
  fi
done

$DOCKER rm "$CID" >/dev/null
rm -rf "$TMPCP" "$CIDFILE"

exit 0
