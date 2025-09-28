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

if [[ -d .git ]]; then
  git rev-parse HEAD >/dist/revision
  git log -1 --format='%ad' --date=short HEAD >/dist/revision_date

  if ! [[ -f version ]]; then
    (git describe --tags HEAD 2>/dev/null || git rev-parse --short=8 HEAD) \
      | sed -e s/^v// >/dist/version
  fi
fi

cd /dist

ID="$ID"
JS_ENGINE="\${JS_ENGINE:-\${ID%_*}}"
if [[ "$ID" == *_* ]]; then
  JS_VARIANT="\${JS_VARIANT:-\${ID#*_}}"
fi

echo "$ARCH" >arch
echo "\$JS_ENGINE" >engine
if [[ -n "\$JS_VARIANT" ]]; then
  echo "\$JS_VARIANT" >variant
fi

if [[ ! -f binary_size && \$(file -b --mime-type "$ID" 2>/dev/null) == */*-executable ]]; then
  ls -l "$ID" 2>/dev/null | sed -e 's/  */ /g' | cut -f 5 -d ' ' >binary_size
fi

# Assemble /dist/$ID.json from value fragments in /dist
{
  echo "{"
  for key in arch engine variant binary_size revision revision_date version; do
    if [[ -f \$key ]]; then
      val=\$(cat "\$key")
    elif [[ -f "\$SRC/\$key" ]]; then
      val=\$(cat "\$SRC/\$key")
    else
      continue
    fi

    if [[ \$key == binary_size ]]; then
      echo "  \"binary_size\": \$val,"
    else
      echo "  \"\$key\": \\"\$val\\","
    fi
    rm -f "\$key"
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
