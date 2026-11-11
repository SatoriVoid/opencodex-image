#!/bin/sh
set -eu

image=${1:?usage: smoke-test.sh IMAGE}
name=opencodex-smoke-$$
ocx_volume=opencodex-smoke-ocx-$$
codex_volume=opencodex-smoke-codex-$$
token=$(openssl rand -hex 32)

cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker volume rm -f "$ocx_volume" "$codex_volume" >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

docker volume create "$ocx_volume" >/dev/null
docker volume create "$codex_volume" >/dev/null

# The upstream image initializes the owner-only API token in its state volume.
printf '%s\n' "$token" \
  | docker run --rm -i \
      -v "$ocx_volume:/home/bun/.opencodex" \
      "$image" bun run docker/bootstrap-token.ts

docker run -d --name "$name" \
  -v "$ocx_volume:/home/bun/.opencodex" \
  -v "$codex_volume:/home/bun/.codex" \
  -p 127.0.0.1::10100 \
  "$image" >/dev/null

port=$(docker port "$name" 10100/tcp | sed -n 's/.*:\([0-9][0-9]*\)$/\1/p')
[ -n "$port" ] || { echo "Cannot determine smoke-test port" >&2; exit 1; }

attempt=0
while [ "$attempt" -lt 45 ]; do
  if curl --fail --silent "http://127.0.0.1:${port}/healthz" >/dev/null \
    && curl --fail --silent "http://127.0.0.1:${port}/readyz" >/dev/null; then
    echo "Smoke test passed"
    exit 0
  fi
  attempt=$((attempt + 1))
  sleep 2
done

docker logs "$name" >&2 || true
echo "OpenCodex did not become ready" >&2
exit 1
