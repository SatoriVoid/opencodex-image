#!/bin/sh
set -eu

upstream_dir=${1:?usage: prepare-tools-dockerfile.sh UPSTREAM_DIR}
append_file=${2:-docker/tools.Dockerfile.append}

[ -f "$upstream_dir/Dockerfile" ] || {
  echo "Upstream Dockerfile not found: $upstream_dir/Dockerfile" >&2
  exit 1
}
[ -f "$append_file" ] || {
  echo "Packaging extension not found: $append_file" >&2
  exit 1
}

cat "$upstream_dir/Dockerfile" "$append_file" > "$upstream_dir/Dockerfile.packaged"
